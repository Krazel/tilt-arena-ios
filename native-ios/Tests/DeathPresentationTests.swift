import XCTest
import SpriteKit
@testable import TiltArena

final class DeathPresentationTests: XCTestCase {
    @MainActor func testDeathSavesResultButBlocksMenusInputAndRestartUntilFragmentsFinish() throws {
        let session = GameSession(), view = SKView(frame: CGRect(x: 0, y: 0, width: 874, height: 402))
        session.posture = .normal; view.presentScene(session.scene); session.scene.play(restart: true)
        let bridge = try ClassicBridge(); _ = try bridge.create(spawning: false)
        let dead = try bridge.finish()
        session.scene.presentDeath(dead)
        XCTAssertEqual(session.phase, .dying)
        XCTAssertEqual(session.resultScore, dead.score)
        XCTAssertTrue(session.scene.deathPresentationPendingForVerification)
        XCTAssertFalse(session.scene.deathPresentationPausedForVerification)
        session.scene.pauseRun(); session.scene.play(restart: true); session.performConfirmed(.restart)
        XCTAssertEqual(session.phase, .dying)
        let before = session.scene.frameForVerification?.time
        session.scene.update(100); session.scene.update(200)
        XCTAssertEqual(session.scene.frameForVerification?.time, before, "Simulation stops immediately")
        session.scene.suspend()
        XCTAssertEqual(session.phase, .dying)
        XCTAssertTrue(session.scene.deathPresentationPendingForVerification)
        XCTAssertTrue(session.scene.deathPresentationPausedForVerification)
        session.scene.resumePresentation()
        XCTAssertFalse(session.scene.deathPresentationPausedForVerification)
        session.scene.menu()
        XCTAssertEqual(session.phase, .menu)
        XCTAssertFalse(session.scene.deathPresentationPendingForVerification, "No late result over a different screen")
        view.presentScene(nil)
    }
}
