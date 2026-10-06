import XCTest
import AVFoundation
@testable import TiltArena

private final class ThreadCheckedPlayback: AudioPlayback {
    var currentTime: TimeInterval = 0 { didSet { check() } }
    var volume: Float = 1 { didSet { check() } }
    var numberOfLoops = 0 { didSet { check() } }
    private var playing = false
    var isPlaying: Bool { check(); return playing }
    var plays = 0, mainThreadCalls = 0
    private func check() { if Thread.isMainThread { mainThreadCalls += 1 } }
    func play() -> Bool { check(); plays += 1; playing = true; return true }
    func pause() { check(); playing = false }
    func stop() { check(); playing = false; currentTime = 0 }
    func prepareToPlay() -> Bool { check(); return true }
}

@MainActor final class AudioDriverTests: XCTestCase {
    func testRealMusicCompletionCrossesBackToAudioOwnerAndAdvancesPlaylist() async throws {
        let advanced = expectation(description: "second native track started")
        let stopped = expectation(description: "audio stopped")
        var players: [String: AVAudioPlayer] = [:], reported = false
        // Short real recordings exercise AVAudioPlayer's actual completion
        // delegate when the player was constructed off the main thread.
        let catalog = ApprovedAudio(menu: "music-menu", playlist: ["music-a", "music-b"], assets: [
            "music-a": .init(file: "audio-ui.wav", volume: 0),
            "music-b": .init(file: "audio-frost.wav", volume: 0)
        ], silent: [])
        let driver = ClassicAudioDriver { owner in
            ClassicSound(catalog: catalog, makePlayer: { asset in
                let file = asset.file as NSString
                let url = Bundle.main.url(forResource: file.deletingPathExtension, withExtension: file.pathExtension)!
                let player = try! AVAudioPlayer(contentsOf: url); players[asset.file] = player; return player
            }, notifications: NotificationCenter(), dispatchCallback: { action in
                owner {
                    XCTAssertFalse(Thread.isMainThread)
                    action()
                    if players["audio-frost.wav"]?.isPlaying == true && !reported {
                        reported = true; advanced.fulfill()
                    }
                }
            })
        }
        driver.startRun()
        await fulfillment(of: [advanced], timeout: 10)
        driver.setSuspended(true)
        driver.afterPending { stopped.fulfill() }; await fulfillment(of: [stopped], timeout: 10)
    }

    func testAudioMailboxPreservesCuesAndControlBarriersWithoutMainThreadAudio() async throws {
        let queue = DispatchQueue(label: "audio-driver-test"), nc = NotificationCenter()
        var players: [String: ThreadCheckedPlayback] = [:]
        let driver = ClassicAudioDriver(queue: queue) { callback in
            ClassicSound(makePlayer: { asset in
                XCTAssertFalse(Thread.isMainThread)
                let p = ThreadCheckedPlayback(); players[asset.file] = p; return p
            }, activateSession: { XCTAssertFalse(Thread.isMainThread) }, deactivateSession: {},
            notifications: nc, dispatchCallback: callback)
        }
        let loaded = expectation(description: "loaded")
        driver.afterPending { loaded.fulfill() }; await fulfillment(of: [loaded], timeout: 10)
        let bridge = try ClassicBridge(), base = try bridge.create(seed: 17, spawning: false)
        func frame(_ t: Double, power: String? = nil) -> ClassicFrame {
            let events = power.map { [ClassicFrame.Event(kind: "pickup", x: nil, y: nil, radius: nil, angle: nil,
                toX: nil, toY: nil, color: nil, power: $0, value: nil, bonus: nil)] } ?? []
            return ClassicFrame(state: base.state, mode: base.mode, time: t, score: base.score, combo: base.combo,
                comboBase: base.comboBase, pendingBonus: base.pendingBonus, bestCombo: base.bestCombo,
                kills: base.kills, comboRemaining: base.comboRemaining, player: base.player, beam: nil,
                enemies: [], pickups: [], projectiles: [], fields: [], events: events)
        }
        queue.suspend()
        driver.startRun()
        driver.consume(frame(0, power: "missiles"))
        for i in 1...600 { driver.consume(frame(Double(i)/60)) }
        driver.pause(); driver.setMuted(true)
        driver.consume(frame(11, power: "bubble"))
        let finished = expectation(description: "ordered")
        driver.afterPending { finished.fulfill() }
        queue.resume()
        await fulfillment(of: [finished], timeout: 10)
        XCTAssertEqual(players["audio-missiles.wav"]?.plays, 1, "Pickup retained despite frame coalescing")
        XCTAssertEqual(players["audio-bubble.wav"]?.plays, 0, "Mute barrier precedes later pickup")
        XCTAssertTrue(players.values.allSatisfy { $0.mainThreadCalls == 0 })
        nc.post(name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
        let recovered = expectation(description: "notification serialized")
        driver.afterPending { recovered.fulfill() }; await fulfillment(of: [recovered], timeout: 10)
        XCTAssertTrue(players.values.allSatisfy { $0.mainThreadCalls == 0 })
        print("NATIVE_AUDIO_DRIVER frames=601 coalesced=true retainedPickup=true muteBarrier=true mainThreadCalls=0")
    }

    func testEveryPowerAndDenseKillsEnqueueWithoutBlockingOnNativePlayers() async throws {
        let driver = ClassicAudioDriver()
        let ready = expectation(description: "native players ready")
        driver.afterPending { ready.fulfill() }; await fulfillment(of: [ready], timeout: 20)
        driver.startRun()
        let bridge = try ClassicBridge(); _ = try bridge.create(seed: 17, spawning: false)
        let base = try bridge.tick(dt: 1.0/60, x: 0, y: 0)
        let cues: [(String,String?)] = [("pickup","spikes"),("pickup","missiles"),("pickup","bubble"),
            ("pickup","burn"),("burnLaunch",nil),("freeze",nil),("blast","nuke"),("blast","bubble"),
            ("pickup","wave"),("wave",nil),("pickup","boomerang"),("boomerangLaunch",nil),
            ("boomerangBounce",nil),("electricPulse",nil),("kill",nil)]
        var samples: [Double] = []
        for (i,cue) in cues.enumerated() {
            let event = ClassicFrame.Event(kind: cue.0, x: nil, y: nil, radius: nil, angle: nil,
                toX: nil, toY: nil, color: nil, power: cue.1, value: nil, bonus: nil)
            let frame = ClassicFrame(state: base.state, mode: base.mode, time: Double(i)*0.3,
                score: base.score, combo: base.combo, comboBase: base.comboBase, pendingBonus: base.pendingBonus,
                bestCombo: base.bestCombo, kills: base.kills, comboRemaining: base.comboRemaining,
                player: base.player, beam: nil, enemies: [], pickups: [], projectiles: [], fields: [], events: [event])
            let start = ProcessInfo.processInfo.systemUptime
            driver.consume(frame)
            samples.append((ProcessInfo.processInfo.systemUptime-start)*1000)
            // Let each cue reach real native playback, instead of measuring only coalescing.
            let played = expectation(description: "cue \(cue.0)")
            driver.afterPending { played.fulfill() }; await fulfillment(of: [played], timeout: 10)
        }
        driver.setMode(.off)
        let stopped = expectation(description: "stopped")
        driver.afterPending { stopped.fulfill() }; await fulfillment(of: [stopped], timeout: 10)
        print("NATIVE_AUDIO_ALL_CUES renderEnqueueMaxMs=\(samples.max()!) cues=\(cues.count) simulatorOnly=true physicalFPS=false")
    }
}
