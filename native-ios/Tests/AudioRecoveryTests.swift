import XCTest
import AVFoundation
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
