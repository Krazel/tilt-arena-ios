import XCTest
import SpriteKit
@testable import TiltArena

final class ClassicBridgeTests: XCTestCase {
    func testExplosionHasDistinctBoundedPhasesAndReducedMotion() throws {
        let blast = ClassicExplosion(radius: 155, color: .orange, reduced: false)
        blast.removeAllActions(); blast.update(elapsed: 0.16)
        let front = try XCTUnwrap(blast.childNode(withName: "shock-front"))
        let core = try XCTUnwrap(blast.childNode(withName: "hot-core"))
        XCTAssertGreaterThan(front.alpha, 0.5); XCTAssertGreaterThan(core.alpha, 0.6)
        XCTAssertEqual(blast.children.filter { $0.name == "fragment" }.count, 12)
        XCTAssertLessThan(blast.calculateAccumulatedFrame().width, 380)
        blast.update(elapsed: 0.4)
        XCTAssertEqual(core.alpha, 0); XCTAssertGreaterThan(front.alpha, 0)
        blast.update(elapsed: 0.7)
        XCTAssertTrue(blast.children.allSatisfy { $0.alpha == 0 })
        let reduced = ClassicExplosion(radius: 155, color: .orange, reduced: true)
        reduced.removeAllActions(); reduced.update(elapsed: 0.16)
        XCTAssertFalse(reduced.children.contains { $0.name == "fragment" })
        XCTAssertEqual(reduced.childNode(withName: "shock-front")?.xScale, 1)
        let frame = try ClassicBridge().explosionFrame(left: 100, right: 1300)
        XCTAssertEqual(frame.pickups.count, 10); XCTAssertEqual(frame.enemies.count, 12)
    }
    func testNewPowersAndLongRangeElectricityDecodeAndHaveDistinctNativeArt() throws {
        let bridge = try ClassicBridge()
        let out = try bridge.newPowersFrame(left: 100, right: 1300)
        let back = try bridge.newPowersFrame(left: 100, right: 1300, returning: true)
        XCTAssertEqual(out.pickups.count, 10)
        XCTAssertTrue(out.pickups.contains { $0.power == "boomerang" })
        XCTAssertFalse(out.pickups.contains { $0.power == "decoy" })
        XCTAssertTrue(out.fields.isEmpty)
        XCTAssertEqual(out.projectiles.first?.kind, "boomerang")
        XCTAssertEqual(out.projectiles.first?.angle, 0)
        XCTAssertLessThan(back.projectiles.first?.angle ?? 0, -2)
        XCTAssertLessThan(back.player.y, out.player.y)
        let electric = try bridge.newPowersFrame(left: 100, right: 1300, electricity: true)
        XCTAssertEqual(electric.kills, 4)
        XCTAssertEqual(electric.events.first { $0.kind == "electricPulse" }?.radius, 220)
        let bolt = try XCTUnwrap(electric.events.first { $0.kind == "lightning" })
        XCTAssertEqual((bolt.toX ?? 0) - (bolt.x ?? 0), 200, accuracy: 0.0001)
        for style in ["boomerang", "boomerangShot"] {
            let art = ClassicArt.node(style: style)
            XCTAssertGreaterThan(art.children.count, 2)
            XCTAssertGreaterThan(art.calculateAccumulatedFrame().width, 35)
        }
    }
    func testSpikesRemainReadableWithBubbleAndAnimateFromSimulationTime() throws {
        let bridge = try ClassicBridge()
        let active = try bridge.spikesVFXFrame(left: 100, right: 1300, warning: false)
        let warning = try bridge.spikesVFXFrame(left: 100, right: 1300, warning: true)
        XCTAssertTrue(active.player.bubble && warning.player.bubble)
        XCTAssertTrue(active.enemies.allSatisfy { hypot($0.x-active.player.x, $0.y-active.player.y) > 110 })
        let node = ClassicSpikes()
        node.update(time: active.time, until: active.player.spikesUntil, heading: active.player.angle, reduced: false)
        XCTAssertFalse(node.isHidden); XCTAssertEqual(node.alpha, 1)
        XCTAssertGreaterThan(node.zPosition, 0)
        XCTAssertGreaterThan(node.calculateAccumulatedFrame().width, 88)
        XCTAssertEqual(cos(Double(node.zRotation) + active.player.angle), cos(active.time * 4.2), accuracy: 0.0001)
        let tooth = try XCTUnwrap(node.children.first as? SKShapeNode)
        let activeColor = tooth.fillColor
        let countdown = try XCTUnwrap(node.childNode(withName: "expiry-ring") as? SKShapeNode)
        XCTAssertTrue(countdown.isHidden)
        let rotation = node.zRotation
        node.update(time: warning.time, until: warning.player.spikesUntil, heading: warning.player.angle, reduced: false)
        XCTAssertNotEqual(node.zRotation, rotation)
        XCTAssertEqual(tooth.alpha, 0.4, accuracy: 0.0001)
        XCTAssertNotEqual(tooth.fillColor, activeColor); XCTAssertFalse(countdown.isHidden)
        let pausedRotation = node.zRotation, pausedAlpha = tooth.alpha
        node.update(time: warning.time, until: warning.player.spikesUntil, heading: warning.player.angle, reduced: false)
        XCTAssertEqual(node.zRotation, pausedRotation); XCTAssertEqual(tooth.alpha, pausedAlpha)
        node.update(time: 4.5, until: 5, heading: 0, reduced: false)
        XCTAssertEqual(tooth.alpha, 1, accuracy: 0.0001)
        node.update(time: 4.5, until: 5, heading: 0.4, reduced: true)
        XCTAssertEqual(node.zRotation, -0.4, accuracy: 0.0001)
        XCTAssertEqual(tooth.alpha, 1, accuracy: 0.0001)
        XCTAssertFalse(countdown.isHidden)
        node.update(time: 5, until: 5, heading: 0, reduced: false)
        XCTAssertTrue(node.isHidden)
    }
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
        for angle in [45.0, 0.0] {
            let profile = TiltProfile.preset(angle == 45 ? .normal : .inclined)
            let radians = (angle + 8) * Double.pi / 180
            let delta = profile.motionDelta(x: sin(radians), y: 0, z: -cos(radians), landscapeRight: false)
            XCTAssertEqual(delta.x, sin(8 * Double.pi / 180), accuracy: 0.00001)
            XCTAssertEqual(delta.y, 0, accuracy: 0.00001)
        }
    }
    func testFlatPresetIsNeutralFaceUpInBothLandscapeOrientations() {
        for right in [false, true] {
            let profile = TiltProfile.preset(.inclined)
            let neutral = profile.motionDelta(x: 0, y: 0, z: -1, landscapeRight: right)
            XCTAssertEqual(neutral.x, 0, accuracy: 0.00001)
            XCTAssertEqual(neutral.y, 0, accuracy: 0.00001)
            let tilted = profile.motionDelta(x: 0.1, y: 0.2, z: -sqrt(0.95), landscapeRight: right)
            XCTAssertGreaterThan(tilted.x, 0)
            XCTAssertGreaterThan(tilted.y, 0)
        }
    }
    func testCalibrationDefaultsAndMigrationPreserveSavedNeutral() {
        let suite = "TiltArenaTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        XCTAssertEqual(TiltProfile.initialPosture(defaults: defaults), .custom)
        defaults.set("inclined", forKey: "classic.posture")
        defaults.set(-0.35, forKey: "classic.neutralY")
        XCTAssertEqual(TiltProfile.initialPosture(defaults: defaults), .custom)
        XCTAssertEqual(defaults.double(forKey: "classic.neutralY"), -0.35)
        defaults.set(2, forKey: "classic.postureRevision")
        XCTAssertEqual(TiltProfile.initialPosture(defaults: defaults), .inclined)
        XCTAssertEqual(TiltPosture.allCases.map(\.title), ["Calibrar", "Normal", "Inclinado"])
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
    func testChargeAndTrailDecodeFromBundledJavaScriptCore() throws {
        let bridge = try ClassicBridge()
        let charge = try bridge.selectedVFXFrame(left: 100, right: 1300, charging: true)
        XCTAssertEqual(charge.player.fireChargeProgress, 0.5, accuracy: 0.00001)
        XCTAssertEqual(charge.player.x, 600, accuracy: 0.00001)
        XCTAssertFalse(charge.fields.contains { $0.kind == "fire" })
        let dash = try bridge.selectedVFXFrame(left: 100, right: 1300, charging: false)
        XCTAssertGreaterThan(dash.player.x, charge.player.x + 200)
        XCTAssertTrue(dash.fields.contains { $0.kind == "fire" && $0.angle == 0 })
    }
    func testWaveChargeAndSteeredFireDecodeWithSmallerVortex() throws {
        let bridge = try ClassicBridge()
        let wave = try bridge.selectedVFXFrame(left: 100, right: 1300, charging: true, wave: true)
        XCTAssertTrue(wave.player.waveCharging)
        XCTAssertEqual(wave.player.waveChargeProgress, 0.5, accuracy: 0.00001)
        XCTAssertTrue(wave.projectiles.isEmpty)
        XCTAssertEqual(wave.fields.first?.radius, 140)
        let shot = try bridge.selectedVFXFrame(left: 100, right: 1300, charging: false, wave: true)
        XCTAssertFalse(shot.player.waveCharging)
        XCTAssertEqual(shot.projectiles.count, 1)
        let turn = try bridge.selectedVFXFrame(left: 100, right: 1300, charging: false, turning: true)
        XCTAssertEqual(turn.player.vy, 1050, accuracy: 0.00001)
        XCTAssertEqual(turn.player.vx, 0, accuracy: 0.00001)
        XCTAssertTrue(turn.fields.contains { $0.kind == "fire" && $0.angle == 0 })
        XCTAssertTrue(turn.fields.contains { $0.kind == "fire" && $0.angle == .pi / 2 })
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
