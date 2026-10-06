import AVFoundation

struct ApprovedAudio: Decodable {
    struct Deployment: Decodable { let count: Int; let interval: Double; let alternates: [String] }
    struct PitchVariant: Decodable { let file: String; let cents: Int }
    struct Asset: Decodable {
        let file: String
        let volume: Float
        let pitchVariants: [PitchVariant]?
        let deployment: Deployment?
        let alternates: [String]?
        init(file: String, volume: Float, pitchVariants: [PitchVariant]? = nil, deployment: Deployment? = nil, alternates: [String]? = nil) {
            self.file = file; self.volume = volume; self.pitchVariants = pitchVariants; self.deployment = deployment
            self.alternates = alternates
        }
    }
    let menu: String
    let playlist: [String]
    let assets: [String: Asset]
    let silent: [String]?
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
                if event.power == "burn" { result.append("burn-charge") }
                if event.power == "boomerang" { result.append("boomerang-charge") }
                if event.power == "wave" { result.append("wave-charge") }
                if let power = event.power, ["missiles", "bubble", "spikes"].contains(power) { result.append(power) }
            case "blast":
                if event.power == "nuke" { result.append("nuke") }
                if event.power == "bubble" { result.append("bubble-break") }
            case "freeze": result.append("frost")
            case "wave": result.append("wave")
            case "kill": result.append(event.frozen == true || event.color == "#70dce9" ? "shatter" : "hit")
            case "electricPulse": result.append("lightning")
            case "burnLaunch": result.append("burn-launch")
            case "boomerangLaunch": result.append("boomerang-launch")
            case "boomerangBounce": result.append("bounce")
            case "boomerangCatch":
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
    private var pitchKeys: [String: [String]] = [:]
    private var lastPitch: [String: Int] = [:]
    private let random: () -> Double
    private let now: () -> Double
    private let makePlayer: (ApprovedAudio.Asset) -> AudioPlayback?
    private let activateSession: () throws -> Void
    private let deactivateSession: () -> Void
    private let notifications: NotificationCenter
    private let dispatchCallback: (@escaping () -> Void) -> Void
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
    private var spikesStart: Double?
    private var nextSpike = 0
    private var nextVoice: [String: Int] = [:]
    private enum LoopState { case idle, playing, paused }
    private var loopStates: [String: LoopState] = [:]
    private var laserVolume: Float?
    private var audible: Bool { !muted && !suspended && !interrupted && !waitingForUser && servicesAvailable }

    init(catalog: ApprovedAudio? = try? ApprovedAudio.load(),
         makePlayer: @escaping (ApprovedAudio.Asset) -> AudioPlayback? = { asset in
             let file = asset.file as NSString
             guard let url = Bundle.main.url(forResource: file.deletingPathExtension, withExtension: file.pathExtension) else { return nil }
             return try? AVAudioPlayer(contentsOf: url)
         }, activateSession: @escaping () throws -> Void = {
             let session = AVAudioSession.sharedInstance()
             // Game audio ignores the Ring/Silent switch; the in-game mute still applies.
             // Preserve ambient's ability to coexist with audio from other apps.
             try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
             try session.setActive(true)
         }, deactivateSession: @escaping () -> Void = {
             try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
         }, notifications: NotificationCenter = .default,
         dispatchCallback: @escaping (@escaping () -> Void) -> Void = { $0() },
         random: @escaping () -> Double = { Double.random(in: 0..<1) },
         now: @escaping () -> Double = { ProcessInfo.processInfo.systemUptime }) {
        self.catalog = catalog; self.makePlayer = makePlayer
        self.activateSession = activateSession; self.deactivateSession = deactivateSession
        self.notifications = notifications
        self.dispatchCallback = dispatchCallback
        self.random = random; self.now = now
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
            self?.sessionActive = false; self?.refreshMusic(); self?.refreshVortex(checkPlayback: true)
        }
    }
    private func observe(_ name: Notification.Name, handler: @escaping (Notification) -> Void) {
        observers.append(notifications.addObserver(forName: name, object: nil, queue: nil) { [weak self] note in
            self?.dispatchCallback { handler(note) }
        })
    }
    private func rebuildPlayers() {
        loopStates.removeAll(); laserVolume = nil
        let position = players[currentMusic ?? ""]?.currentTime ?? 0
        players.values.forEach { $0.stop() }; players.removeAll(); pitchKeys.removeAll()
        nextVoice.removeAll()
        for (name, asset) in catalog?.assets ?? [:] {
            guard let player = makePlayer(asset) else { continue }
            player.volume = asset.volume; (player as? AVAudioPlayer)?.delegate = self
            player.numberOfLoops = ["music-menu", "vortex", "laser"].contains(name) ? -1 : 0
            _ = player.prepareToPlay(); players[name] = player
            if let variants = asset.pitchVariants, !variants.isEmpty, !name.hasPrefix("music") {
                var keys = [name]
                for (index, variant) in variants.enumerated() {
                    guard let pitched = makePlayer(.init(file: variant.file, volume: asset.volume)) else { continue }
                    let key = "\(name)#pitch\(index)"
                    pitched.volume = asset.volume; pitched.numberOfLoops = 0
                    _ = pitched.prepareToPlay(); players[key] = pitched; keys.append(key)
                }
                pitchKeys[name] = keys
            }
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
        refreshMusic(); refreshVortex(checkPlayback: true)
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
        if value { players.values.forEach { $0.pause() }; pauseLoopStates(); sessionActive = false; deactivateSession() }
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
                pauseLoopStates()
            } else { clearEffects(); vortexWanted = false; laserRemaining = 0 }
        } else if previous == .paused && audible {
            for name in pausedEffects { playPlayer(name) }; pausedEffects.removeAll()
        }
        refreshMusic(); refreshVortex(checkPlayback: true)
    }
    func pause() { setMode(.paused) }
    func playMusic() { setMode(.game) }
    func uiClick() { recoverFromUserAction(); play("ui") }
    private func clearEffects() {
        loopStates.removeAll()
        nextVoice.removeAll()
        spikesStart = nil; nextSpike = 0
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
            if ready && name == wanted { if !player.isPlaying { playPlayer(name) } } else if player.isPlaying { player.pause() }
        }
    }
    private func pauseLoopStates() {
        for name in ["vortex", "laser"] where loopStates[name] == .playing { loopStates[name] = .paused }
    }
    private func synchronizeLoop(_ name: String, wanted: Bool, checkPlayback: Bool) {
        let state = loopStates[name] ?? .idle
        if !wanted {
            // AVAudioPlayer seeking is native audio work, even for a silent
            // player. Reset once at expiry, never 60 times/second while idle.
            if state != .idle {
                players[name]?.pause(); players[name]?.currentTime = 0
                pausedEffects.remove(name); loopStates[name] = .idle
            }
        } else if audible && mode == .game {
            if state != .playing || (checkPlayback && players[name]?.isPlaying != true) {
                if players[name]?.isPlaying != true { playPlayer(name) }
                loopStates[name] = players[name]?.isPlaying == true ? .playing : .paused
            }
        } else if state == .playing {
            players[name]?.pause(); loopStates[name] = .paused
        }
    }
    private func refreshVortex(checkPlayback: Bool = false) {
        synchronizeLoop("vortex", wanted: vortexWanted, checkPlayback: checkPlayback)
        if laserRemaining > 0 {
            let volume = (catalog?.assets["laser"]?.volume ?? 0.48) * Float(min(1, laserRemaining / 0.12))
            if laserVolume != volume { players["laser"]?.volume = volume; laserVolume = volume }
        }
        synchronizeLoop("laser", wanted: laserRemaining > 0, checkPlayback: checkPlayback)
    }
    func consume(_ frame: ClassicFrame) {
        guard mode == .game, ["running", "gameOver"].contains(frame.state), lastFrameTime != frame.time else { return }
        lastFrameTime = frame.time
        laserRemaining = frame.state == "running" ? frame.player.laserRemaining : 0
        vortexWanted = frame.fields.contains { $0.kind == "vortex" && $0.remaining > 0 }
        let now = self.now()
        let healthCheck = now - lastHealthCheck >= 1
        if healthCheck { lastHealthCheck = now; refreshMusic() }
        refreshVortex(checkPlayback: healthCheck)
        for cue in AudioCuePolicy.cues(events: frame.events, boomerangCharging: frame.player.boomerangCharging) {
            if cue != "spikes" || frame.state == "running" { play(cue) }
        }
        if frame.state == "running" { advanceSpikes(at: frame.time) } else { spikesStart = nil }
    }
    private func advanceSpikes(at time: Double) {
        guard audible, mode == .game, let start = spikesStart,
              let deployment = catalog?.assets["spikes"]?.deployment,
              deployment.count > 0, deployment.interval > 0 else { return }
        // Skip overdue beats after a stalled frame instead of playing a burst all at once.
        let beat = min(deployment.count - 1, max(0, Int(floor((time - start + 0.0000001) / deployment.interval))))
        guard beat >= nextSpike else { return }
        let voices = ["spikes"] + deployment.alternates
        let name = voices[beat % voices.count]
        players[name]?.currentTime = 0; playPlayer(name)
        nextSpike = beat + 1
        if nextSpike >= deployment.count { spikesStart = nil }
    }
    private func play(_ cue: String) {
        guard catalog?.silent?.contains(cue) != true, audible, cue == "ui" || mode == .game else { return }
        let now = self.now()
        let interval = cue == "hit" || cue == "shatter" ? 0.07 : cue == "bounce" ? 0.05 : 0.015
        guard now - (lastCue[cue] ?? -100) >= interval else { return }; lastCue[cue] = now
        if cue == "spikes", let deployment = catalog?.assets[cue]?.deployment, let time = lastFrameTime {
            for name in [cue] + deployment.alternates { players[name]?.stop(); pausedEffects.remove(name) }
            spikesStart = time; nextSpike = 0
            return
        }
        var name = cue
        if cue == "shatter" { name = shatterIndex % 2 == 0 ? "shatter-a" : "shatter-b"; shatterIndex += 1 }
        if cue.hasSuffix("-launch") { players[cue.replacingOccurrences(of: "-launch", with: "-charge")]?.stop() }
        if cue == "wave" { players["wave-charge"]?.stop() }
        if let alternates = catalog?.assets[name]?.alternates, !alternates.isEmpty {
            let keys = [name] + alternates, index = nextVoice[name, default: 0] % (alternates.count + 1)
            nextVoice[name] = (index + 1) % keys.count
            name = keys[index]
        }
        if let keys = pitchKeys[name], keys.count > 1 {
            // Death voices share one pitch history, so consecutive kills differ
            // even when the next overlapping playback voice is selected.
            let history = cue == "hit" ? cue : name
            let previous = lastPitch[history]
            let count = keys.count - (previous == nil ? 0 : 1)
            var index = min(count - 1, max(0, Int(random() * Double(count))))
            if let previous, index >= previous { index += 1 }
            lastPitch[history] = index
            // Preserve the single-voice policy when retriggering the shield.
            if cue != "hit" { for key in keys { players[key]?.stop() } }
            name = keys[index]
        }
        players[name]?.currentTime = 0; playPlayer(name)
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        dispatchCallback { [weak self] in
            guard let self, self.mode == .game, let name = self.currentMusic, self.players[name] === player else { return }
            self.advanceTrack(); self.players[self.currentMusic ?? ""]?.currentTime = 0; self.refreshMusic()
        }
    }
}
