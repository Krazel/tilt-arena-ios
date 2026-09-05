import AVFoundation

final class ClassicSound {
    private var music: AVAudioPlayer?
    private var effects: [String: AVAudioPlayer] = [:]
    private var muted = false
    private var musicWanted = false
    private var lastHit = 0.0
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        for name in ["classic-loop", "pickup", "hit", "death"] {
            guard let url=Bundle.main.url(forResource:name,withExtension:"wav"),
                  let player=try? AVAudioPlayer(contentsOf:url) else {continue}
            player.prepareToPlay()
            if name == "classic-loop" {music=player;player.numberOfLoops = -1;player.volume=0.3}
            else {effects[name]=player;player.volume=0.45}
        }
    }
    func setMuted(_ value: Bool) {
        muted=value
        if value {music?.pause();effects.values.forEach{$0.stop()}}
        else if musicWanted {music?.play()}
    }
    func playMusic() {musicWanted=true;if !muted {music?.play()}}
    func pause() {musicWanted=false;music?.pause();effects.values.forEach{$0.pause()}}
    func play(_ name: String) {
        guard !muted else {return}
        let now=ProcessInfo.processInfo.systemUptime
        if name == "hit" {if now-lastHit<0.06{return};lastHit=now}
        effects[name]?.currentTime=0;effects[name]?.play()
    }
}
