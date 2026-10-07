import XCTest
@testable import TiltArena

final class SpeedTrialTests: XCTestCase {
    func testEveryTrialSpeedReachesItsLimitAndCanChangeAfterPause() throws {
        let bridge = try ClassicBridge()
        for speed in SpeedTrial.values {
            _ = try bridge.create(seed: 17, spawning: false, playerSpeed: speed)
            _ = try bridge.resize(left: -10000, right: 10000, bottom: -10000, top: 10000)
            var frame = try bridge.tick(dt: 0, x: 0, y: 0)
            for _ in 0..<60 { frame = try bridge.tick(dt: 1.0 / 60, x: 1, y: 0) }
            XCTAssertEqual(frame.player.vx, Double(speed), accuracy: 0.01)
            try bridge.pause(); try bridge.setPlayerSpeed(600); try bridge.resume()
            for _ in 0..<60 { frame = try bridge.tick(dt: 1.0 / 60, x: 1, y: 0) }
            XCTAssertEqual(frame.player.vx, 600, accuracy: 0.01)
        }
    }
    @MainActor func testTrialPreferenceDefaultsTo600PersistsAndCannotChangeDuringPlay() throws {
        let name = "SpeedTrialTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let session = GameSession(defaults: defaults)
        XCTAssertEqual(session.trialSpeed, 600)
        session.selectTrialSpeed(720)
        XCTAssertEqual(GameSession(defaults: defaults).trialSpeed, 720)
        session.selectTrialSpeed(999); XCTAssertEqual(session.trialSpeed, 720)
        session.phase = .running; session.selectTrialSpeed(840); XCTAssertEqual(session.trialSpeed, 720)
        session.phase = .paused; session.selectTrialSpeed(780); XCTAssertEqual(session.trialSpeed, 780)
        session.phase = .gameOver; session.selectTrialSpeed(660); XCTAssertEqual(session.trialSpeed, 660)
        defaults.set(999, forKey: SpeedTrial.key); XCTAssertEqual(SpeedTrial.read(defaults), 600)
    }
}
