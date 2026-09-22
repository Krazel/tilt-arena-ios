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

/// Only approved cues. An unreviewed or rejected effect is silent.
enum AudioCuePolicy {
    static func cues(events: [ClassicFrame.Event], boomerangCharging: Bool) -> [String] {
        var result: [String] = []
        for event in events {
            switch event.kind {
            case "pickup":
                result.append("pickup")
                if event.power == "burn" { result.append("burn-charge") }
                if event.power == "boomerang" { result.append("boomerang-charge") }
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

final class ClassicSound: NSObject, AVAudioPlayerDelegate {
    enum Mode { case menu, game, paused, off }
    private let catalog: ApprovedAudio?
    private var players: [String: AVAudioPlayer] = [:]
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
    private var interruptionObserver: NSObjectProtocol?
    private var audible: Bool { !muted && !suspended && !interrupted }

    override init() {
        catalog = try? ApprovedAudio.load()
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        for (name, asset) in catalog?.assets ?? [:] {
            let file = asset.file as NSString
            guard let url = Bundle.main.url(forResource: file.deletingPathExtension, withExtension: file.pathExtension),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.volume = asset.volume; player.delegate = self
            player.numberOfLoops = name == "music-menu" || name == "vortex" ? -1 : 0
            player.prepareToPlay(); players[name] = player
        }
        interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] note in
            guard let self, let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
            self.interrupted = raw == AVAudioSession.InterruptionType.began.rawValue
            if self.interrupted { self.players.values.forEach { $0.pause() } }
            else { self.refreshMusic() }
        }
    }
    deinit { if let interruptionObserver { NotificationCenter.default.removeObserver(interruptionObserver) } }
    func setMuted(_ value: Bool) {
        muted = value
        if value { players.values.forEach { $0.pause() }; clearEffects() }
        else { refreshMusic(); refreshVortex() }
    }
    func setSuspended(_ value: Bool) {
        suspended = value
        if value { players.values.forEach { $0.pause() } }
        else { refreshMusic() }
    }
    func startRun() {
        clearEffects(); lastCue.removeAll(); lastFrameTime = nil; vortexWanted = false
        advanceTrack(); players[currentMusic ?? ""]?.currentTime = 0
        mode = .game; refreshMusic()
    }
    func setMode(_ next: Mode) {
        let previous = mode; mode = next
        if next != .game {
            if next == .paused {
                for (name, player) in players where !name.hasPrefix("music") && name != "ui" && player.isPlaying {
                    pausedEffects.insert(name); player.pause()
                }
            } else { clearEffects(); vortexWanted = false }
        } else if previous == .paused && audible {
            for name in pausedEffects { players[name]?.play() }; pausedEffects.removeAll()
        }
        refreshMusic(); refreshVortex()
    }
    func pause() { setMode(.paused) }
    func playMusic() { setMode(.game) }
    func uiClick() { play("ui") }
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
        for (name, player) in players where name.hasPrefix("music") {
            if audible && name == wanted { player.play() } else { player.pause() }
        }
    }
    private func refreshVortex() {
        if audible && mode == .game && vortexWanted { if players["vortex"]?.isPlaying != true { players["vortex"]?.play() } }
        else { players["vortex"]?.pause(); if !vortexWanted { players["vortex"]?.currentTime = 0 } }
    }
    func consume(_ frame: ClassicFrame) {
        guard mode == .game, frame.state == "running", lastFrameTime != frame.time else { return }
        lastFrameTime = frame.time
        vortexWanted = frame.fields.contains { $0.kind == "vortex" && $0.remaining > 0 }
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
        players[name]?.currentTime = 0; players[name]?.play()
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard mode == .game, let name = currentMusic, players[name] === player else { return }
        advanceTrack(); players[currentMusic ?? ""]?.currentTime = 0; refreshMusic()
    }
}
