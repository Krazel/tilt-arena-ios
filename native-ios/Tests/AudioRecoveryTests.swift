import XCTest
import AVFoundation
import JavaScriptCore
@testable import TiltArena

private final class FakePlayback: AudioPlayback {
    var currentTime: TimeInterval = 0
    var volume: Float = 1
    var numberOfLoops = 0
    var isPlaying = false
    var plays = 0
    func play() -> Bool { isPlaying = true; plays += 1; return true }
    func pause() { isPlaying = false }
    func stop() { isPlaying = false; currentTime = 0 }
    func prepareToPlay() -> Bool { true }
}
@MainActor final class AudioRecoveryTests: XCTestCase {
    func testDeathAUsesFourFullVoicesAndKeepsMutePauseAndFrozenRouting() throws {
        let catalog = try ApprovedAudio.load(), asset = try XCTUnwrap(catalog.assets["hit"])
        let keys = ["hit"] + (asset.alternates ?? [])
        XCTAssertEqual(keys.count, 4)
        var players: [String: FakePlayback] = [:], clock: Double = 0
        let sound = ClassicSound(catalog: catalog, makePlayer: { a in let p=FakePlayback();players[a.file]=p;return p }, activateSession: {}, deactivateSession: {}, notifications: NotificationCenter(), now: { clock })
        let voices = try keys.map { try XCTUnwrap(players[try XCTUnwrap(catalog.assets[$0]).file]) }
        let base = try ClassicBridge().create(seed: 11, spawning: false)
        let event = ClassicFrame.Event(kind: "kill", x: nil, y: nil, radius: nil, angle: nil, toX: nil, toY: nil, color: nil, power: nil, value: nil, bonus: nil)
        func frame(_ time: Double) -> ClassicFrame {
            clock = time
            return ClassicFrame(state: base.state, mode: base.mode, time: time, score: base.score, combo: base.combo, comboBase: base.comboBase, pendingBonus: base.pendingBonus, bestCombo: base.bestCombo, kills: base.kills, comboRemaining: base.comboRemaining, player: base.player, beam: base.beam, enemies: base.enemies, pickups: base.pickups, projectiles: base.projectiles, fields: base.fields, events: [event])
        }
        sound.startRun();players["audio-music-a.mp3"]?.currentTime = 42
        for i in 0..<4 { sound.consume(frame(Double(i)*0.071));voices[i].currentTime = 0.01 }
        XCTAssertEqual(voices.map(\.plays), [1,1,1,1]);XCTAssertEqual(voices[0].currentTime, 0.01)
        sound.consume(frame(0.22));XCTAssertEqual(voices.map(\.plays), [1,1,1,1])
        sound.consume(frame(0.284));XCTAssertEqual(voices.map(\.plays), [2,1,1,1])
        sound.pause();XCTAssertTrue(voices.allSatisfy { !$0.isPlaying })
        sound.playMusic();XCTAssertTrue(voices.allSatisfy { $0.isPlaying })
        XCTAssertEqual(players["audio-music-a.mp3"]?.currentTime, 42)
        sound.setMuted(true);sound.consume(frame(1));XCTAssertTrue(voices.allSatisfy { !$0.isPlaying && $0.currentTime == 0 })
        sound.setMuted(false);sound.setMode(.menu);XCTAssertTrue(voices.allSatisfy { !$0.isPlaying })
        sound.startRun();sound.consume(frame(2));XCTAssertEqual(voices[0].plays, 4)
        var frozen = event;frozen.frozen = true
        XCTAssertEqual(AudioCuePolicy.cues(events: [frozen], boomerangCharging: false), ["shatter"])
        XCTAssertEqual(AudioCuePolicy.cues(events: Array(repeating: event, count: 20), boomerangCharging: false), ["hit"])
    }
    func testSpikesDeploymentPreservesCompleteTailsAndHonorsPauseMuteAndStalledFrames() throws {
        let catalog = try ApprovedAudio.load(), base = try ClassicBridge().create(seed: 11, spawning: false)
        let deployment = try XCTUnwrap(catalog.assets["spikes"]?.deployment)
        XCTAssertEqual(deployment.count, 8); XCTAssertEqual(deployment.interval, 0.04)
        let keys = ["spikes"] + deployment.alternates
        XCTAssertEqual(keys.count, 4)
        var players: [String: FakePlayback] = [:], clock: Double = 0
        let sound = ClassicSound(catalog: catalog, makePlayer: { a in let p=FakePlayback();players[a.file]=p;return p }, activateSession: {}, deactivateSession: {}, notifications: NotificationCenter(), now: { clock })
        let voices = try keys.map { try XCTUnwrap(players[try XCTUnwrap(catalog.assets[$0]).file]) }
        let pickup = ClassicFrame.Event(kind: "pickup", x: nil, y: nil, radius: nil, angle: nil, toX: nil, toY: nil, color: nil, power: "spikes", value: nil, bonus: nil)
        func frame(_ time: Double, pickup includePickup: Bool = false, state: String = "running") -> ClassicFrame {
            clock = time
            return ClassicFrame(state: state, mode: base.mode, time: time, score: base.score, combo: base.combo, comboBase: base.comboBase, pendingBonus: base.pendingBonus, bestCombo: base.bestCombo, kills: base.kills, comboRemaining: base.comboRemaining, player: base.player, beam: base.beam, enemies: base.enemies, pickups: base.pickups, projectiles: base.projectiles, fields: base.fields, events: includePickup ? [pickup] : [])
        }
        func count() -> Int { voices.reduce(0) { $0 + $1.plays } }
        sound.startRun(); players["audio-music-a.mp3"]?.currentTime = 42
        sound.consume(frame(0, pickup: true)); XCTAssertEqual(count(), 1)
        voices[0].currentTime = 0.11
        sound.consume(frame(0.04)); sound.consume(frame(0.04)); XCTAssertEqual(count(), 2)
        sound.consume(frame(0.08)); XCTAssertEqual(voices[0].currentTime, 0.11)
        for beat in 3..<8 { sound.consume(frame(Double(beat) * 0.04)) }
        XCTAssertEqual(voices.map(\.plays), [2, 2, 2, 2]); sound.consume(frame(0.95)); XCTAssertEqual(count(), 8)
        XCTAssertEqual(players["audio-music-a.mp3"]?.currentTime, 42)
        sound.startRun(); sound.consume(frame(1, pickup: true)); sound.pause()
        sound.setSuspended(true); sound.consume(frame(1.04)); let paused = count()
        sound.setSuspended(false); XCTAssertTrue(voices.allSatisfy { !$0.isPlaying })
        sound.playMusic(); let resumed = count(); sound.consume(frame(1.04)); XCTAssertEqual(count(), resumed + 1)
        XCTAssertGreaterThanOrEqual(resumed, paused)
        sound.setMuted(true); let muted = count(); sound.setMuted(false); sound.consume(frame(1.5)); XCTAssertEqual(count(), muted)
        sound.startRun(); sound.consume(frame(2, pickup: true)); let start = count()
        sound.consume(frame(2.17)); XCTAssertEqual(count(), start + 1)
        sound.consume(frame(2.18)); XCTAssertEqual(count(), start + 1)
        sound.consume(frame(3, pickup: true)); let repeated = count()
        sound.consume(frame(3.02)); XCTAssertEqual(count(), repeated)
        sound.consume(frame(3.04)); XCTAssertEqual(count(), repeated + 1)
        sound.consume(frame(3.2, state: "gameOver")); let dead = count()
        sound.consume(frame(3.6)); XCTAssertEqual(count(), dead)
    }
    func testShieldCollisionPlaysSelectedBreakOnceAndRespectsMuteAndPause() throws {
        let source = try String(contentsOf: XCTUnwrap(Bundle.main.url(forResource: "classic-core", withExtension: "js")), encoding: .utf8)
        let context = try XCTUnwrap(JSContext())
        context.evaluateScript("globalThis.CLASSIC_DIAGNOSTICS = true;")
        context.evaluateScript(source)
        let json = try XCTUnwrap(context.evaluateScript("""
        (function(){const g=new ClassicDiagnostics.ClassicGame(17,{spawning:false});
          g.activate('bubble');const frames=[g.snapshot()];g.events=[];
          g.addEnemy(g.player.x+30,g.player.y,{speed:0,activeAt:0});
          g.advance(1/120);frames.push(g.snapshot());g.advance(1/120);frames.push(g.snapshot());
          return JSON.stringify(frames);})()
        """)?.toString())
        XCTAssertNil(context.exception, context.exception?.toString() ?? "")
        let frames = try JSONDecoder().decode([ClassicFrame].self, from: Data(json.utf8))
        XCTAssertTrue(frames[0].player.bubble); XCTAssertFalse(frames[1].player.bubble)
        XCTAssertEqual(frames[1].events.filter { $0.kind == "blast" && $0.power == "bubble" }.count, 1)
        var players: [String: FakePlayback] = [:]
        let sound = ClassicSound(makePlayer: { a in let p=FakePlayback();players[a.file]=p;return p }, activateSession: {}, deactivateSession: {}, notifications: NotificationCenter())
        let breakVoice = try XCTUnwrap(players["audio-bubble-break.wav"])
        sound.startRun(); sound.consume(frames[0]); XCTAssertEqual(breakVoice.plays, 0)
        sound.consume(frames[1]); XCTAssertEqual(breakVoice.plays, 1)
        XCTAssertEqual(breakVoice.volume, 0.65, accuracy: 0.0001)
        sound.consume(frames[1]); sound.consume(frames[2]); XCTAssertEqual(breakVoice.plays, 1)
        breakVoice.currentTime=0.4; sound.pause(); XCTAssertFalse(breakVoice.isPlaying)
        sound.playMusic(); XCTAssertTrue(breakVoice.isPlaying); XCTAssertEqual(breakVoice.currentTime, 0.4)
        sound.setMuted(true); XCTAssertFalse(breakVoice.isPlaying)
        sound.startRun(); sound.consume(frames[0]); sound.consume(frames[1])
        XCTAssertEqual(breakVoice.plays, 2) // Resume above; the muted collision adds no play.
        XCTAssertFalse(breakVoice.isPlaying)
    }
    func testVortexFromRealSimulationStartsImmediatelyAndHonorsPauseMuteAndExpiry() throws {
        let source = try String(contentsOf: XCTUnwrap(Bundle.main.url(forResource: "classic-core", withExtension: "js")), encoding: .utf8)
        let context = try XCTUnwrap(JSContext())
        context.evaluateScript("globalThis.CLASSIC_DIAGNOSTICS = true;")
        context.evaluateScript(source)
        let json = try XCTUnwrap(context.evaluateScript("""
        (function(){const g=new ClassicDiagnostics.ClassicGame(17,{spawning:false});
          g.activate('vortex');const frames=[g.snapshot()];
          for(let i=0;i<240;i++)g.advance(1/120);frames.push(g.snapshot());
          for(let i=0;i<241;i++)g.advance(1/120);frames.push(g.snapshot());
          return JSON.stringify(frames);})()
        """)?.toString())
        XCTAssertNil(context.exception, context.exception?.toString() ?? "")
        let frames = try JSONDecoder().decode([ClassicFrame].self, from: Data(json.utf8))
        XCTAssertTrue(frames[0].fields.contains { $0.kind == "vortex" && $0.remaining > 0 })
        XCTAssertTrue(frames[2].fields.isEmpty)
        var players: [String: FakePlayback] = [:]
        let sound = ClassicSound(makePlayer: { asset in let p=FakePlayback(); players[asset.file]=p; return p }, activateSession: {}, deactivateSession: {}, notifications: NotificationCenter())
        sound.startRun(); sound.consume(frames[0])
        let vortex = try XCTUnwrap(players["audio-vortex.wav"])
        XCTAssertTrue(vortex.isPlaying); XCTAssertEqual(vortex.plays, 1)
        XCTAssertGreaterThan(vortex.volume, try XCTUnwrap(players["audio-music-a.mp3"]).volume)
        XCTAssertEqual(vortex.numberOfLoops, -1)
        vortex.currentTime = 0.8
        sound.pause(); XCTAssertFalse(vortex.isPlaying)
        sound.playMusic(); XCTAssertTrue(vortex.isPlaying); XCTAssertEqual(vortex.currentTime, 0.8)
        sound.consume(frames[1]); XCTAssertTrue(vortex.isPlaying)
        sound.setMuted(true); XCTAssertFalse(vortex.isPlaying)
        sound.setMuted(false); XCTAssertTrue(vortex.isPlaying)
        sound.setSuspended(true); XCTAssertFalse(vortex.isPlaying)
        sound.setSuspended(false); XCTAssertTrue(vortex.isPlaying)
        sound.consume(frames[2]); XCTAssertFalse(vortex.isPlaying); XCTAssertEqual(vortex.currentTime, 0)
        sound.pause(); sound.playMusic(); XCTAssertFalse(vortex.isPlaying)
    }
    func testRealSessionUsesPlaybackAndKeepsInGameMuteAndSuspension() throws {
        let session = AVAudioSession.sharedInstance()
        let previousCategory = session.category, previousMode = session.mode, previousOptions = session.categoryOptions
        let nc = NotificationCenter()
        var players: [String: FakePlayback] = [:]
        let sound = ClassicSound(makePlayer: { asset in
            let p = FakePlayback(); players[asset.file] = p; return p
        }, notifications: nc)
        defer {
            sound.setSuspended(true)
            try? session.setCategory(previousCategory, mode: previousMode, options: previousOptions)
        }
        try session.setCategory(.ambient, mode: .default)
        sound.setMode(.menu)
        XCTAssertEqual(session.category, .playback)
        XCTAssertEqual(session.mode, .default)
        XCTAssertTrue(session.categoryOptions.contains(.mixWithOthers))
        XCTAssertTrue(try XCTUnwrap(players["audio-music-menu.mp3"]).isPlaying)
        sound.uiClick()
        XCTAssertTrue(try XCTUnwrap(players["audio-ui.wav"]).isPlaying)
        sound.setMuted(true)
        XCTAssertTrue(players.values.allSatisfy { !$0.isPlaying })
        sound.setSuspended(true); sound.setSuspended(false)
        XCTAssertTrue(players.values.allSatisfy { !$0.isPlaying })
        sound.setMuted(false)
        XCTAssertTrue(try XCTUnwrap(players["audio-music-menu.mp3"]).isPlaying)
        // Re-activation after a route change must restore the same silent-switch policy.
        try session.setCategory(.ambient, mode: .default)
        nc.post(name: AVAudioSession.routeChangeNotification, object: nil)
        XCTAssertEqual(session.category, .playback)
        XCTAssertTrue(session.categoryOptions.contains(.mixWithOthers))
        sound.setSuspended(true)
        XCTAssertTrue(players.values.allSatisfy { !$0.isPlaying })
    }
    func testShieldPitchDoesNotRepeatAndResumesTheSameVoiceWithoutTouchingMusic() throws {
        let catalog = try ApprovedAudio.load(), base = try ClassicBridge().create(seed: 11, spawning: false)
        var players: [String: FakePlayback] = [:], clock: Double = 0, random: Double = 0
        let sound = ClassicSound(catalog: catalog, makePlayer: { a in let p=FakePlayback();players[a.file]=p;return p }, activateSession: {}, deactivateSession: {}, notifications: NotificationCenter(), random: { random }, now: { clock })
        let bubble = try XCTUnwrap(catalog.assets["bubble"])
        let files = [bubble.file] + (bubble.pitchVariants ?? []).map(\.file)
        let event = ClassicFrame.Event(kind: "pickup", x: nil, y: nil, radius: nil, angle: nil, toX: nil, toY: nil, color: nil, power: "bubble", value: nil, bonus: nil)
        sound.startRun(); players["audio-music-a.mp3"]?.currentTime = 42
        var selected: [String] = []
        for value in [0.0, 0.0, 0.999, 0.999, 0.5, 0.5] {
            clock += 1; random = value
            let frame = ClassicFrame(state: base.state, mode: base.mode, time: clock, score: base.score, combo: base.combo, comboBase: base.comboBase, pendingBonus: base.pendingBonus, bestCombo: base.bestCombo, kills: base.kills, comboRemaining: base.comboRemaining, player: base.player, beam: base.beam, enemies: base.enemies, pickups: base.pickups, projectiles: base.projectiles, fields: base.fields, events: [event])
            sound.consume(frame)
            let active = files.filter { players[$0]?.isPlaying == true }
            XCTAssertEqual(active.count, 1)
            let file = try XCTUnwrap(active.first); selected.append(file)
            XCTAssertEqual(players[file]?.volume, bubble.volume)
        }
        for index in 1..<selected.count { XCTAssertNotEqual(selected[index], selected[index-1]) }
        let voice = try XCTUnwrap(players[selected.last!]); voice.currentTime = 0.2
        sound.pause(); XCTAssertFalse(voice.isPlaying); sound.playMusic()
        XCTAssertTrue(voice.isPlaying); XCTAssertEqual(voice.currentTime, 0.2)
        XCTAssertEqual(players["audio-music-a.mp3"]?.currentTime, 42)
        sound.setMuted(true); XCTAssertTrue(files.allSatisfy { players[$0]?.isPlaying == false })
    }
    func testInterruptionAndMissingEndRecoverWithoutRestartingRun() throws {
        let nc = NotificationCenter(), catalog = try ApprovedAudio.load()
        var players: [String: FakePlayback] = [:], activations = 0
        let sound = ClassicSound(catalog: catalog, makePlayer: { a in let p=FakePlayback();players[a.file]=p;return p }, activateSession: { activations += 1 }, deactivateSession: {}, notifications: nc)
        sound.startRun(); let music = try XCTUnwrap(players["audio-music-a.mp3"]);music.currentTime=42
        nc.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        XCTAssertFalse(music.isPlaying)
        nc.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.ended.rawValue, AVAudioSessionInterruptionOptionKey: AVAudioSession.InterruptionOptions.shouldResume.rawValue])
        XCTAssertTrue(music.isPlaying);XCTAssertEqual(music.currentTime,42);XCTAssertEqual(activations,2)
        nc.post(name: AVAudioSession.interruptionNotification, object: nil, userInfo: [AVAudioSessionInterruptionTypeKey: AVAudioSession.InterruptionType.began.rawValue])
        sound.setSuspended(true);sound.setSuspended(false)
        XCTAssertTrue(music.isPlaying);XCTAssertEqual(music.currentTime,42)
    }
    func testMediaResetRebuildsPlayersAndWaitsForUserWhileRespectingMute() throws {
        let nc=NotificationCenter();var players:[String:FakePlayback]=[:]
        let sound=ClassicSound(makePlayer:{a in let p=FakePlayback();players[a.file]=p;return p},activateSession:{},deactivateSession:{},notifications:nc)
        sound.startRun();let old=try XCTUnwrap(players["audio-music-a.mp3"]);old.currentTime=37
        nc.post(name:AVAudioSession.mediaServicesWereLostNotification,object:nil)
        nc.post(name:AVAudioSession.mediaServicesWereResetNotification,object:nil)
        let new=try XCTUnwrap(players["audio-music-a.mp3"])
        XCTAssertFalse(new === old);XCTAssertFalse(new.isPlaying);XCTAssertEqual(new.currentTime,37)
        sound.uiClick();XCTAssertTrue(new.isPlaying)
        sound.setMuted(true);nc.post(name:AVAudioSession.mediaServicesWereResetNotification,object:nil);sound.uiClick()
        XCTAssertTrue(players.values.allSatisfy{!$0.isPlaying})
        sound.setMuted(false);XCTAssertTrue(players["audio-music-a.mp3"]!.isPlaying)
    }
    func testActivationFailureCanRetryAndLaserLoopStopsAtPauseMuteAndExpiry() throws {
        enum Failure:Error{case unavailable};var attempts=0;var players:[String:FakePlayback]=[:]
        let sound=ClassicSound(makePlayer:{a in let p=FakePlayback();players[a.file]=p;return p},activateSession:{attempts+=1;if attempts==1{throw Failure.unavailable}},deactivateSession:{},notifications:NotificationCenter())
        sound.setMode(.menu);XCTAssertFalse(players["audio-music-menu.mp3"]!.isPlaying)
        sound.uiClick();XCTAssertTrue(players["audio-music-menu.mp3"]!.isPlaying)
        sound.startRun();let bridge=try ClassicBridge();let frame=try bridge.laserFrame(left:100,right:1300)
        sound.consume(frame);let laser=try XCTUnwrap(players["audio-laser.wav"]);XCTAssertTrue(laser.isPlaying)
        sound.pause();XCTAssertFalse(laser.isPlaying);sound.playMusic();XCTAssertTrue(laser.isPlaying)
        sound.setMuted(true);XCTAssertFalse(laser.isPlaying);sound.setMuted(false);XCTAssertTrue(laser.isPlaying)
        sound.consume(try bridge.create(seed:58,spawning:false));XCTAssertFalse(laser.isPlaying)
    }
}
