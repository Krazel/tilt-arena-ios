import XCTest
import SpriteKit
@testable import TiltArena

final class VisualThemeTests: XCTestCase {
    func testThemePersistenceDoesNotTouchRecordsOrCalibration() {
        let suite = "TiltArenaThemeTests.\(UUID().uuidString)"
        let saved = UserDefaults(suiteName: suite)!
        defer { saved.removePersistentDomain(forName: suite) }
        saved.set(713, forKey: ClassicScoreRecord.key); saved.set(0.42, forKey: "classic.neutralY")
        XCTAssertEqual(VisualTheme.read(defaults: saved), .inkTide)
        VisualTheme.classic.save(defaults: saved)
        XCTAssertEqual(VisualTheme.read(defaults: UserDefaults(suiteName: suite)!), .classic)
        VisualTheme.inkTide.save(defaults: saved)
        XCTAssertEqual(saved.integer(forKey: ClassicScoreRecord.key), 713)
        XCTAssertEqual(saved.double(forKey: "classic.neutralY"), 0.42)
    }
    @MainActor func testSwitchingBothThemesWhilePausedPreservesSimulationAndResumes() throws {
        let session = GameSession(), view = SKView(frame: CGRect(x: 0, y: 0, width: 874, height: 402))
        session.posture = .normal; view.presentScene(session.scene)
        session.scene.play(restart: true); session.scene.pauseRun()
        let before = try XCTUnwrap(session.scene.frameForVerification)
        for theme in [VisualTheme.classic, .inkTide, .classic, .inkTide] {
            session.scene.setTheme(theme)
            let after = try XCTUnwrap(session.scene.frameForVerification)
            XCTAssertEqual(after.time, before.time); XCTAssertEqual(after.score, before.score)
            XCTAssertEqual(after.player.x, before.player.x); XCTAssertEqual(after.player.y, before.player.y)
            XCTAssertEqual(after.pickups.map(\.id), before.pickups.map(\.id))
            XCTAssertEqual(session.phase, .paused)
        }
        session.scene.play(restart: false); XCTAssertEqual(session.phase, .running)
        session.scene.halt(); view.presentScene(nil)
    }
    @MainActor func testLingeringFieldsDecodeAndArtFollowsRemainingGameTime() throws {
        let frame = try ClassicBridge().lingeringAreasFrame(left: 100, right: 1300)
        XCTAssertEqual(frame.time, 0.9, accuracy: 0.0001)
        XCTAssertEqual(frame.fields.count, 2); XCTAssertEqual(frame.pickups.count, 10)
        XCTAssertTrue(frame.pickups.allSatisfy { $0.angle.isFinite })
        for field in frame.fields {
            XCTAssertGreaterThan(field.remaining, 0.29)
            for theme in VisualTheme.allCases {
                let effect = ClassicAreaEffect(kind: field.kind, radius: CGFloat(field.radius), theme: theme, reduced: false)
                effect.update(remaining: field.remaining, duration: field.duration)
                XCTAssertEqual(effect.alpha, 1)
                XCTAssertGreaterThan(effect.calculateAccumulatedFrame().width, CGFloat(field.radius))
                effect.update(remaining: 0, duration: field.duration)
                XCTAssertEqual(effect.alpha, 0)
            }
        }
        XCTAssertEqual(Set(InkArt.orbColors.values).count, 10)
    }
    func testProductionInkAtlasHasAlphaAndAllEightCellsContainVisibleArt() throws {
        let image = try XCTUnwrap(UIImage(named: "ink-tide-sprites")?.cgImage)
        XCTAssertNotEqual(image.alphaInfo, .none)
        var pixels = [UInt8](repeating: 0, count: 128 * 64 * 4)
        let context = try XCTUnwrap(CGContext(data: &pixels, width: 128, height: 64, bitsPerComponent: 8, bytesPerRow: 128 * 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(image, in: CGRect(x: 0, y: 0, width: 128, height: 64))
        for row in 0..<2 { for column in 0..<4 {
            var visible = 0, clear = 0
            for y in row*32..<(row+1)*32 { for x in column*32..<(column+1)*32 {
                let alpha = pixels[(y*128+x)*4+3]
                if alpha > 100 { visible += 1 }; if alpha < 10 { clear += 1 }
            }}
            XCTAssertGreaterThan(visible, 25); XCTAssertGreaterThan(clear, 100)
        }}
        XCTAssertGreaterThan(InkArt.arena.size().width, 1000)
    }
}
