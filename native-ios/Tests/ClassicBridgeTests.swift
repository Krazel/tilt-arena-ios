import XCTest
@testable import TiltArena

final class ClassicBridgeTests: XCTestCase {
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
