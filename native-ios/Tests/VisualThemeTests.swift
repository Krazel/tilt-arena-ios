import XCTest
import SpriteKit
@testable import TiltArena

final class VisualThemeTests: XCTestCase {
    func testApprovedMenuArtworkAndBrushFontAreBundled() throws {
        XCTAssertEqual(try XCTUnwrap(InkMenuArt.panel.cgImage).width, 1848)
        XCTAssertEqual(InkMenuArt.pieces.count, 6)
        for piece in InkMenuArt.Piece.allCases {
            let image = try XCTUnwrap(InkMenuArt.pieces[piece]?.cgImage)
            XCTAssertEqual(image.width, Int(piece.rect.width))
            XCTAssertEqual(image.height, Int(piece.rect.height))
        }
        XCTAssertNotNil(UIFont(name: "Knewave-Regular", size: 23))
    }
    @MainActor func testConfirmedRestartAndMenuRetainModeAndPosture() throws {
        let session = GameSession(), view = SKView(frame: CGRect(x: 0, y: 0, width: 874, height: 402))
        session.selectMode(.hard); session.saveCustom(TiltProfile(screenX: 0.12, screenY: -0.41))
        view.presentScene(session.scene); session.scene.play(restart: true); session.scene.pauseRun()
        let profile = session.activeProfile
        session.performConfirmed(.restart)
        XCTAssertEqual(session.phase, .running); XCTAssertEqual(session.mode, .hard)
        XCTAssertEqual(session.activeProfile.screenX, profile.screenX); XCTAssertEqual(session.activeProfile.screenY, profile.screenY)
        XCTAssertEqual(try XCTUnwrap(session.scene.frameForVerification).score, 0)
        session.scene.pauseRun(); session.performConfirmed(.mainMenu)
        XCTAssertEqual(session.phase, .menu); XCTAssertEqual(session.mode, .hard); XCTAssertTrue(session.hasCustom)
        session.scene.halt(); view.presentScene(nil)
    }

    func testApprovedDrawingsLoadAsCompleteMaskedImagesWithoutReplacementGlyphs() throws {
        XCTAssertEqual(Set(ApprovedOrbArt.regions.keys), Set(["nuke", "wave", "frost", "bubble", "lightning"]))
        for power in ApprovedOrbArt.regions.keys {
            let node = try XCTUnwrap(InkArt.node(style: power) as? SKCropNode)
            XCTAssertNotNil(node.maskNode)
            XCTAssertEqual(node.children.count, 1)
            let art = try XCTUnwrap(node.children.first as? SKSpriteNode)
            XCTAssertEqual(try XCTUnwrap(art.texture).size(), CGSize(width: 256, height: 256))
            XCTAssertEqual(art.colorBlendFactor, 0)
            XCTAssertTrue(art.children.isEmpty)
            XCTAssertGreaterThan(art.size.width * 56 / 42, 50)
            XCTAssertLessThan(art.size.width * 56 / 42, 60)
        }
        XCTAssertNil(ApprovedOrbArt.node(for: "missiles"))
    }
    func testSubtlePigmentPreservesCreamRimAndInkTextureLuminance() {
        let target = [0.5, 0.388, 0.149], rim = [0.93, 0.89, 0.78]
        XCTAssertEqual(InkArt.pigment(rim, target: target), rim)
        let dark = InkArt.pigment([0.08, 0.25, 0.28], target: target)
        let light = InkArt.pigment([0.12, 0.32, 0.35], target: target)
        let lum: ([Double]) -> Double = { 0.2126*$0[0] + 0.7152*$0[1] + 0.0722*$0[2] }
        XCTAssertEqual(lum(dark), lum([0.08, 0.25, 0.28]), accuracy: 0.0001)
        XCTAssertGreaterThan(lum(light), lum(dark)); XCTAssertGreaterThan(dark[0], dark[2])
    }

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
