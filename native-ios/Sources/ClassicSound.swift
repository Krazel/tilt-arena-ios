import AVFoundation

struct ApprovedAudio: Decodable {
    struct Asset: Decodable { let file: String; let volume: Float }
    let menu: String
    let playlist: [String]
    let assets: [String: Asset]
    static func load(bundle: Bundle = .main) throws -> ApprovedAudio {
        let url = bundle.url(forResource: "audio-approved", withExtension: "json")!
        return try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
    }
}

/// User-selected cues plus the explicitly requested 0.5.8 power effects.
enum AudioCuePolicy {
    static func cues(events: [ClassicFrame.Event], boomerangCharging: Bool) -> [String] {
        var result: [String] = []
        for event in events {
            switch event.kind {
            case "pickup":
                result.append("pickup")
                if event.power == "burn" { result.append("burn-charge") }
                if event.power == "boomerang" { result.append("boomerang-charge") }
                if let power = event.power, ["missiles", "bubble", "spikes"].contains(power) { result.append(power) }
            case "blast": if event.power == "nuke" { result.append("nuke") }
            case "freeze": result.append("frost")
            case "wave": result.append("wave")
            case "kill": result.append(event.frozen == true || event.color == "#70dce9" ? "shatter" : "hit")
            case "electricPulse": result.append("lightning")
            case "burnLaunch": result.append("burn-launch")
            case "boomerangLaunch": result.append("boomerang-launch")
            case "boomerangBounce": result.append("bounce")
            case "boomerangCatch":
                result.append("pickup")
                if boomerangCharging { result.append("boomerang-charge") }
            default: break
            }
        }
        var seen = Set<String>()
        return result.filter { seen.insert($0).inserted }
    }
}

protocol AudioPlayback: AnyObject {
    var currentTime: TimeInterval { get set }
    var volume: Float { get set }
    var numberOfLoops: Int { get set }
    var isPlaying: Bool { get }
    func play() -> Bool
    func pause()
    func stop()
    func prepareToPlay() -> Bool
}
extension AVAudioPlayer: AudioPlayback {}

final class ClassicSound: NSObject, AVAudioPlayerDelegate {
    enum Mode { case menu, game, paused, off }
    private let catalog: ApprovedAudio?
    private var players: [String: AudioPlayback] = [:]
    private let makePlayer: (ApprovedAudio.Asset) -> AudioPlayback?
    private let activateSession: () throws -> Void
    private let deactivateSession: () -> Void
    private let notifications: NotificationCenter
    private var observers: [NSObjectProtocol] = []
    private var sessionActive = false
    private var servicesAvailable = true
    private var waitingForUser = false
    private var lastHealthCheck: Double = -100
    private var mode: Mode = .off
    private var muted = false
    private var suspended = false
    private var interrupted = false
    private var playlistIndex = -1
    private var currentMusic: String?
    private var pausedEffects = Set<String>()
    private var lastCue: [String: Double] = [:]
    private var lastFrameTime: Double?
    private var shatterIndex = 0
    private var vortexWanted = false
    private var laserRemaining: Double = 0
    private var audible: Bool { !muted && !suspended && !interrupted && !waitingForUser && servicesAvailable }

    init(catalog: ApprovedAudio? = try? ApprovedAudio.load(),
         makePlayer: @escaping (ApprovedAudio.Asset) -> AudioPlayback? = { asset in
             let file = asset.file as NSString
             guard let url = Bundle.main.url(forResource: file.deletingPathExtension, withExtension: file.pathExtension) else { return nil }
             return try? AVAudioPlayer(contentsOf: url)
         }, activateSession: @escaping () throws -> Void = {
             let session = AVAudioSession.sharedInstance()
             try session.setCategory(.ambient, mode: .default)
             try session.setActive(true)
         }, deactivateSession: @escaping () -> Void = {
             try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
         }, notifications: NotificationCenter = .default) {
        self.catalog = catalog; self.makePlayer = makePlayer
        self.activateSession = activateSession; self.deactivateSession = deactivateSession
        self.notifications = notifications
        super.init()
        rebuildPlayers()
        observe(AVAudioSession.interruptionNotification) { [weak self] note in
            guard let self, let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
            if raw == AVAudioSession.InterruptionType.began.rawValue {
                self.interrupted = true; self.sessionActive = false
                self.players.values.forEach { $0.pause() }; self.clearEffects()
            } else {
                self.interrupted = false
                let options = (note.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt) ?? 0
                self.waitingForUser = !AVAudioSession.InterruptionOptions(rawValue: options).contains(.shouldResume)
                self.refreshMusic(); self.refreshVortex()
            }
        }
        observe(AVAudioSession.mediaServicesWereLostNotification) { [weak self] _ in
            self?.servicesAvailable = false; self?.sessionActive = false
            self?.players.values.forEach { $0.pause() }
        }
        observe(AVAudioSession.mediaServicesWereResetNotification) { [weak self] _ in
            guard let self else { return }
            self.servicesAvailable = true; self.sessionActive = false; self.interrupted = false
            self.waitingForUser = true; self.pausedEffects.removeAll(); self.rebuildPlayers()
        }
        observe(AVAudioSession.routeChangeNotification) { [weak self] _ in
            self?.sessionActive = false; self?.refreshMusic(); self?.refreshVortex()
        }
    }
    private func observe(_ name: Notification.Name, handler: @escaping (Notification) -> Void) {
        observers.append(notifications.addObserver(forName: name, object: nil, queue: .main, using: handler))
    }
    private func rebuildPlayers() {
        let position = players[currentMusic ?? ""]?.currentTime ?? 0
        players.values.forEach { $0.stop() }; players.removeAll()
        for (name, asset) in catalog?.assets ?? [:] {
            guard let player = makePlayer(asset) else { continue }
            player.volume = asset.volume; (player as? AVAudioPlayer)?.delegate = self
            player.numberOfLoops = ["music-menu", "vortex", "laser"].contains(name) ? -1 : 0
            _ = player.prepareToPlay(); players[name] = player
        }
        players[currentMusic ?? ""]?.currentTime = position
    }
    private func ensureSession() -> Bool {
        guard audible else { return false }
        if sessionActive { return true }
        do { try activateSession(); sessionActive = true; return true }
        catch { sessionActive = false; return false }
    }
    /// An explicit action/foreground entry also recovers a missing interruption-ended notification.
    private func recoverFromUserAction() {
        guard !muted, !suspended, servicesAvailable else { return }
        interrupted = false; waitingForUser = false
        refreshMusic(); refreshVortex()
    }
    private func playPlayer(_ name: String) {
        guard ensureSession(), let player = players[name] else { return }
        if !player.play() {
            sessionActive = false
            if ensureSession() { _ = player.prepareToPlay(); _ = player.play() }
        }
    }
    deinit { for observer in observers { notifications.removeObserver(observer) } }
    func setMuted(_ value: Bool) {
        muted = value
        if value { players.values.forEach { $0.pause() }; clearEffects() }
        else { recoverFromUserAction() }
    }
    func setSuspended(_ value: Bool) {
        suspended = value
        if value { players.values.forEach { $0.pause() }; sessionActive = false; deactivateSession() }
        else { recoverFromUserAction() }
    }
    func startRun() {
        clearEffects(); lastCue.removeAll(); lastFrameTime = nil; vortexWanted = false; laserRemaining = 0
        advanceTrack(); players[currentMusic ?? ""]?.currentTime = 0
        mode = .game; recoverFromUserAction()
    }
    func setMode(_ next: Mode) {
        let previous = mode; mode = next
        if next != .game {
            if next == .paused {
                for (name, player) in players where !name.hasPrefix("music") && name != "ui" && player.isPlaying {
                    pausedEffects.insert(name); player.pause()
                }
            } else { clearEffects(); vortexWanted = false; laserRemaining = 0 }
        } else if previous == .paused && audible {
            for name in pausedEffects { playPlayer(name) }; pausedEffects.removeAll()
        }
        refreshMusic(); refreshVortex()
    }
    func pause() { setMode(.paused) }
    func playMusic() { setMode(.game) }
    func uiClick() { recoverFromUserAction(); play("ui") }
    private func clearEffects() {
        for (name, player) in players where !name.hasPrefix("music") && name != "ui" { player.stop(); player.currentTime = 0 }
        pausedEffects.removeAll()
    }
    private func advanceTrack() {
        guard let playlist = catalog?.playlist, !playlist.isEmpty else { return }
        playlistIndex = (playlistIndex + 1) % playlist.count; currentMusic = playlist[playlistIndex]
    }
    private func refreshMusic() {
        let wanted = mode == .menu ? catalog?.menu : mode == .game ? currentMusic : nil
        let ready = audible && wanted != nil && ensureSession()
        for (name, player) in players where name.hasPrefix("music") {
            if ready && name == wanted { if !player.isPlaying { playPlayer(name) } } else { player.pause() }
        }
    }
    private func refreshVortex() {
        if audible && mode == .game && vortexWanted { if players["vortex"]?.isPlaying != true { playPlayer("vortex") } }
        else { players["vortex"]?.pause(); if !vortexWanted { players["vortex"]?.currentTime = 0 } }
        if audible && mode == .game && laserRemaining > 0 {
            players["laser"]?.volume = (catalog?.assets["laser"]?.volume ?? 0.48) * Float(min(1, laserRemaining / 0.12))
            if players["laser"]?.isPlaying != true { playPlayer("laser") }
        } else { players["laser"]?.pause(); if laserRemaining <= 0 { players["laser"]?.currentTime = 0 } }
    }
    func consume(_ frame: ClassicFrame) {
        guard mode == .game, ["running", "gameOver"].contains(frame.state), lastFrameTime != frame.time else { return }
        lastFrameTime = frame.time
        laserRemaining = frame.state == "running" ? frame.player.laserRemaining : 0
        vortexWanted = frame.fields.contains { $0.kind == "vortex" && $0.remaining > 0 }
        let now = ProcessInfo.processInfo.systemUptime
        if now - lastHealthCheck >= 1 { lastHealthCheck = now; refreshMusic() }
        refreshVortex()
        for cue in AudioCuePolicy.cues(events: frame.events, boomerangCharging: frame.player.boomerangCharging) { play(cue) }
    }
    private func play(_ cue: String) {
        guard audible, cue == "ui" || mode == .game else { return }
        let now = ProcessInfo.processInfo.systemUptime
        let interval = cue == "hit" || cue == "shatter" ? 0.07 : cue == "bounce" ? 0.05 : 0.015
        guard now - (lastCue[cue] ?? -100) >= interval else { return }; lastCue[cue] = now
        var name = cue
        if cue == "shatter" { name = shatterIndex % 2 == 0 ? "shatter-a" : "shatter-b"; shatterIndex += 1 }
        if cue.hasSuffix("-launch") { players[cue.replacingOccurrences(of: "-launch", with: "-charge")]?.stop() }
        players[name]?.currentTime = 0; playPlayer(name)
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard mode == .game, let name = currentMusic, players[name] === player else { return }
        advanceTrack(); players[currentMusic ?? ""]?.currentTime = 0; refreshMusic()
    }
}
