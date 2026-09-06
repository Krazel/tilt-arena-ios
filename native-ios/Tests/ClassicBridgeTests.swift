import XCTest
@testable import TiltArena

final class ClassicBridgeTests: XCTestCase {
    func testSavedPostureWorksInEitherLandscapeOrientation() throws {
        let profile = TiltProfile.sampled(x: 0.6, y: 0.1, landscapeRight: false)
        let left = profile.deviceNeutral(landscapeRight: false)
        let right = profile.deviceNeutral(landscapeRight: true)
        XCTAssertEqual(left.x, 0.6, accuracy: 0.00001)
        XCTAssertEqual(right.x, -0.6, accuracy: 0.00001)
        let bridge = try ClassicBridge()
        let neutral = try bridge.tilt(gx: right.x, gy: right.y, nx: right.x, ny: right.y, orientation: "landscapeRight", sensitivity: 1)
        XCTAssertEqual(neutral.0, 0); XCTAssertEqual(neutral.1, 0)
        XCTAssertNotEqual(TiltProfile.preset(.normal).screenY, TiltProfile.preset(.inclined).screenY)
    }
    func testPostureAnglesHaveEquivalentResponse() {
        for angle in [45.0, 70.0] {
            let profile = TiltProfile.preset(angle == 45 ? .normal : .inclined)
            let radians = (angle + 8) * Double.pi / 180
            let delta = profile.motionDelta(x: sin(radians), y: 0, z: -cos(radians), landscapeRight: false)
            XCTAssertEqual(delta.x, sin(8 * Double.pi / 180), accuracy: 0.00001)
            XCTAssertEqual(delta.y, 0, accuracy: 0.00001)
        }
    }
    @MainActor func testSceneFillsWideDisplayAndResumeDoesNotCalibrate() {
        let session = GameSession()
        session.posture = .normal
        session.scene.configureViewport(viewSize: CGSize(width: 874, height: 402), insets: .zero)
        XCTAssertEqual(session.scene.size.width / session.scene.size.height, 874.0 / 402, accuracy: 0.0001)
        session.scene.play(restart: true)
        session.scene.pauseRun()
        XCTAssertEqual(session.phase, .paused)
        session.scene.play(restart: false)
        XCTAssertEqual(session.phase, .running)
        session.scene.pauseRun()
        session.scene.calibrate(restart: false)
        session.scene.cancelCalibration()
        XCTAssertEqual(session.phase, .paused)
        session.scene.halt()
    }
    func testGeneratedTexturesAreBundledAndLoaded() {
        XCTAssertGreaterThan(ClassicArt.orb.size().width, 10)
        XCTAssertGreaterThan(ClassicArt.spark.size().width, 10)
    }
    func testBundledEngineLoadsAndMoves() throws {
        let bridge = try ClassicBridge()
        let initial = try bridge.create(seed: 17)
        XCTAssertEqual(initial.state, "running")
        XCTAssertEqual(initial.pickups.count, 2)
        let next = try bridge.tick(dt: 0.1, x: 1, y: 0)
        XCTAssertGreaterThan(next.player.x, initial.player.x)
        XCTAssertEqual(next.player.y, initial.player.y)
    }
    func testPauseAndFinishUseSameScoringEngine() throws {
        let bridge = try ClassicBridge()
        _ = try bridge.create(seed: 18)
        let before = try bridge.tick(dt: 0.1, x: 0, y: 0)
        try bridge.pause()
        let paused = try bridge.tick(dt: 30, x: 1, y: 1)
        XCTAssertEqual(paused.time, before.time)
        XCTAssertEqual(paused.state, "paused")
        XCTAssertEqual(try bridge.finish().state, "gameOver")
    }
    func testScreenOrientationMapping() throws {
        let bridge = try ClassicBridge()
        let left = try bridge.tilt(gx: 0, gy: 0.2, nx: 0, ny: 0,
                                   orientation: "landscapeLeft", sensitivity: 1)
        let right = try bridge.tilt(gx: 0, gy: -0.2, nx: 0, ny: 0,
                                    orientation: "landscapeRight", sensitivity: 1)
        XCTAssertGreaterThan(left.0, 0)
        XCTAssertEqual(left.0, right.0, accuracy: 0.00001)
    }
}
