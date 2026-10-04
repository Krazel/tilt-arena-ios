import XCTest
@testable import TiltArena

final class TiltProfileTests: XCTestCase {
    func testCalibrationIgnoresRollAndStraighteningPhoneDoesNotDrift() throws {
        for right in [false, true] {
            for face in [-1.0, 1.0] {
                for pitch in [-65.0, 0.0, 45.0, 80.0] {
                    let angle = pitch * .pi / 180
                    for roll in [-35.0, 0.0, 35.0] {
                        let r = roll * .pi / 180
                        let g = gravity(sin(r), sin(angle) * cos(r), face * cos(angle) * cos(r), right: right)
                        let p = try XCTUnwrap(TiltProfile.capture(x: g.x, y: g.y, z: g.z, timestamp: 1, now: 1, landscapeRight: right))
                        XCTAssertEqual(p.screenX, 0)
                        XCTAssertEqual(p.screenY, sin(angle), accuracy: 1e-12)
                        let straight = gravity(0, sin(angle), face * cos(angle), right: right)
                        let d = p.motionDelta(x: straight.x, y: straight.y, z: straight.z, landscapeRight: right)
                        XCTAssertEqual(d.x, 0, accuracy: 1e-12); XCTAssertEqual(d.y, 0, accuracy: 1e-12)
                    }
                }
            }
        }
        XCTAssertNil(TiltProfile.capture(x: 0, y: 1, z: 0, timestamp: 1, now: 1, landscapeRight: false))
    }
    private func gravity(_ sx: Double, _ sy: Double, _ z: Double, right: Bool) -> (x: Double, y: Double, z: Double) {
        right ? (sy, -sx, z) : (-sy, sx, z)
    }
    func testNeutralAcrossBothFacesAnglesAndLandscapeDirections() throws {
        for right in [false, true] {
            for face in [-1.0, 1.0] {
                for sx in [-0.2, 0, 0.2] {
                    for sy in [-0.8, -0.3, 0, 0.3, 0.8] {
                        for scale in [0.9, 1.0, 1.1] {
                            let g = gravity(sx * scale, sy * scale, face * sqrt(1 - sx*sx - sy*sy) * scale, right: right)
                            let p = try XCTUnwrap(TiltProfile.capture(x: g.x, y: g.y, z: g.z, timestamp: 1, now: 1, landscapeRight: right))
                            let d = p.motionDelta(x: g.x, y: g.y, z: g.z, landscapeRight: right)
                            XCTAssertEqual(d.x, 0, accuracy: 1e-12)
                            XCTAssertEqual(d.y, right ? -sx : sx, accuracy: 1e-12)
                            XCTAssertEqual(p.screenX, 0)
                            XCTAssertEqual(p.screenZ.sign, (-face).sign)
                        }
                    }
                }
            }
        }
    }
    func testLoweringEachScreenEdgeHasSameDirectionFaceUpAndDown() throws {
        for right in [false, true] {
            for face in [-1.0, 1.0] {
                let p = try XCTUnwrap(TiltProfile.capture(x: 0, y: 0, z: face, timestamp: 1, now: 1, landscapeRight: right))
                for angle in [-12.0, -4.0, 4.0, 12.0] {
                    let s = sin(angle * .pi / 180), c = cos(angle * .pi / 180)
                    for horizontal in [false, true] {
                        let g = gravity(horizontal ? s : 0, horizontal ? 0 : s, face * c, right: right)
                        let d = p.motionDelta(x: g.x, y: g.y, z: g.z, landscapeRight: right)
                        let screenDX = right ? -d.y : d.y, screenDY = right ? d.x : -d.x
                        XCTAssertEqual(screenDX, horizontal ? s : 0, accuracy: 1e-12)
                        XCTAssertEqual(screenDY, horizontal ? 0 : s, accuracy: 1e-12)
                    }
                }
            }
        }
    }
    func testObliqueFaceDownResponseMatchesExistingFaceUpSensitivity() throws {
        for right in [false, true] {
            for sy in [-0.7, 0.0, 0.7] {
                let up = gravity(0.2, sy, -sqrt(1 - 0.04 - sy*sy), right: right)
                let a = try XCTUnwrap(TiltProfile.capture(x: up.x, y: up.y, z: up.z, timestamp: 1, now: 1, landscapeRight: right))
                let b = try XCTUnwrap(TiltProfile.capture(x: up.x, y: up.y, z: -up.z, timestamp: 1, now: 1, landscapeRight: right))
                for offset in [-0.05, 0.05] {
                    let g = gravity(0.2 + offset, sy + offset, -sqrt(1 - pow(0.2 + offset, 2) - pow(sy + offset, 2)), right: right)
                    let da = a.motionDelta(x: g.x, y: g.y, z: g.z, landscapeRight: right)
                    let db = b.motionDelta(x: g.x, y: g.y, z: -g.z, landscapeRight: right)
                    XCTAssertEqual(da.x, db.x, accuracy: 1e-12)
                    XCTAssertEqual(da.y, db.y, accuracy: 1e-12)
                }
            }
        }
    }
    func testFaceDownNeutralSurvivesSavingAndLandscapeFlip() throws {
        let name = "TiltProfileTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let p = try XCTUnwrap(TiltProfile.capture(x: 0.4, y: 0.2, z: sqrt(0.8), timestamp: 1, now: 1, landscapeRight: false))
        p.save(defaults: defaults)
        let restored = TiltProfile.saved(defaults: defaults)
        XCTAssertEqual(restored.screenZ, p.screenZ)
        for right in [false, true] {
            let g = restored.deviceNeutral(landscapeRight: right)
            let d = restored.motionDelta(x: g.x, y: g.y, z: -restored.screenZ, landscapeRight: right)
            XCTAssertEqual(d.x, 0, accuracy: 1e-12); XCTAssertEqual(d.y, 0, accuracy: 1e-12)
        }
    }
    func testLegacySavedPostureKeepsFaceUpNeutral() {
        let name = "TiltProfileTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(0.2, forKey: "classic.neutralX")
        defaults.set(-0.4, forKey: "classic.neutralY")
        let p = TiltProfile.saved(defaults: defaults)
        XCTAssertEqual(p.screenX, 0)
        XCTAssertEqual(p.screenZ, sqrt(0.8) / sqrt(0.96), accuracy: 1e-12)
        let d = p.motionDelta(x: 0.4, y: 0.2, z: -sqrt(0.8), landscapeRight: false)
        XCTAssertEqual(d.x, 0, accuracy: 1e-12); XCTAssertEqual(d.y, 0.2, accuracy: 1e-12)
    }
    func testCrossingVerticalDoesNotFlipTheCapturedFacingSign() throws {
        for face in [-1.0, 1.0] {
            let a = 88.0 * Double.pi / 180
            let p = try XCTUnwrap(TiltProfile.capture(x: sin(a), y: 0, z: face * cos(a), timestamp: 1, now: 1, landscapeRight: false))
            for degrees in [89.0, 90.0, 91.0, 92.0] {
                let b = degrees * Double.pi / 180
                let d = p.motionDelta(x: sin(b), y: 0, z: face * cos(b), landscapeRight: false)
                XCTAssertEqual(d.x, sin(b - a), accuracy: 1e-12)
                XCTAssertEqual(d.y, 0, accuracy: 1e-12)
            }
        }
    }
}
