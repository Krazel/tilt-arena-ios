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
    @MainActor func testFinalSpeedIgnoresSavedTrialValuesAndCannotBeChanged() throws {
        let name = "SpeedTrialTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        XCTAssertFalse(SpeedTrial.enabled)
        for previous in [600, 660, 720, 780, 840, 999] {
            defaults.set(previous, forKey: SpeedTrial.key)
            let session = GameSession(defaults: defaults)
            XCTAssertEqual(session.trialSpeed, 600)
            for phase in [GameSession.Phase.menu, .paused, .gameOver, .running] {
                session.phase = phase; session.selectTrialSpeed(840)
                XCTAssertEqual(session.trialSpeed, 600)
            }
        }
    }
}
