import XCTest
import SpriteKit
@testable import TiltArena

final class VisualThemeTests: XCTestCase {
    @MainActor func testApprovedLightningIsBoundedDeterministicAndExpires() throws {
        let frame = try ClassicBridge().newPowersFrame(left: 50, right: 1250, electricity: true)
        let event = try XCTUnwrap(frame.events.first { $0.kind == "lightning" })
        for reduced in [false, true] {
            let node = ClassicLightning(event: event, reduced: reduced); node.removeAllActions()
            XCTAssertEqual(node.children.count, 6)
            node.update(age: 0.08)
            let path = try XCTUnwrap((node.children[1] as? SKShapeNode)?.path)
            XCTAssertEqual(path.currentPoint.x, (event.toX ?? 0) - (event.x ?? 0), accuracy: 0.001)
            XCTAssertEqual(path.currentPoint.y, (event.toY ?? 0) - (event.y ?? 0), accuracy: 0.001)
            let bounds = node.calculateAccumulatedFrame(); node.update(age: 0.08)
            XCTAssertEqual(node.calculateAccumulatedFrame(), bounds)
            node.update(age: 0.55)
            XCTAssertTrue(node.children.allSatisfy { $0.isHidden || $0.alpha == 0 })
        }
    }
    @MainActor func testLaserTrialStylesPreserveSegmentAndBoundNodes() throws {
        let frame = try ClassicBridge().laserFrame(left: 100, right: 1300), beam = try XCTUnwrap(frame.beam)
        let node = ClassicLaser()
        for theme in VisualTheme.allCases { for style in LaserStyle.allCases {
            node.update(beam: beam, remaining: 0.95, time: 1, theme: theme, reduced: false, style: style)
            XCTAssertEqual(node.position.x, beam.x, accuracy: 0.001)
            XCTAssertEqual(node.position.y, beam.y, accuracy: 0.001)
            var count = 0; node.enumerateChildNodes(withName: "//*") { _, _ in count += 1 }
            XCTAssertLessThan(count, 25)
            node.update(beam: nil, remaining: 0, time: 2, theme: theme, reduced: false, style: style)
            XCTAssertTrue(node.isHidden)
        } }
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "laser-test-" + UUID().uuidString))
        XCTAssertEqual(LaserStyle.read(defaults: defaults), .current)
        LaserStyle.inkBeam.save(defaults: defaults); XCTAssertEqual(LaserStyle.read(defaults: defaults), .inkBeam)
        defaults.set("unknown", forKey: LaserStyle.key); XCTAssertEqual(LaserStyle.read(defaults: defaults), .current)
    }
    @MainActor func testApprovedDeathHasThirteenMovingFragmentsAndExpires() throws {
        let node = ClassicDeathEffect(reduced: false); node.removeAllActions()
        XCTAssertEqual(node.children.count, 14)
        node.update(age: 0.2); let position = node.children[1].position
        node.update(age: 0.5); XCTAssertNotEqual(node.children[1].position, position)
        let bounds = node.calculateAccumulatedFrame(); node.update(age: 0.5)
        XCTAssertEqual(node.calculateAccumulatedFrame(), bounds)
        node.update(age: 2.4); XCTAssertTrue(node.children.allSatisfy { $0.alpha < 0.001 })
    }

    @MainActor func testLaserUsesDecodedSegmentAndStopsRenderingAtExpiry() throws {
        let frame = try ClassicBridge().laserFrame(left: 100, right: 1300)
        let beam = try XCTUnwrap(frame.beam)
        XCTAssertEqual(beam.x, 304, accuracy: 0.001); XCTAssertEqual(beam.toX, 760, accuracy: 0.001)
        XCTAssertEqual(frame.player.laserRemaining, 0.95, accuracy: 0.001)
        XCTAssertEqual(frame.pickups.count, 11)
        let image = try XCTUnwrap(UIImage(named: "ink-wave-orb-v058")?.cgImage)
        XCTAssertEqual(image.width, 1536); XCTAssertEqual(image.height, 1024)
        for theme in VisualTheme.allCases {
            let node = ClassicLaser()
            node.update(beam: beam, remaining: 0.95, time: frame.time, theme: theme, reduced: true)
            XCTAssertFalse(node.isHidden)
            XCTAssertEqual((node.children[0] as? SKShapeNode)?.lineWidth, 12)
            node.update(beam: nil, remaining: 0, time: 2, theme: theme, reduced: true)
            XCTAssertTrue(node.isHidden)
        }
    }
    func testFrozenInkUsesBlueAlphaMaskInsteadOfMultiplyingRedPigment() throws {
        let image = try XCTUnwrap(InkArt.frozenAtlasImage.cgImage)
        let cell = try XCTUnwrap(image.cropping(to: CGRect(x: image.width / 4, y: 0, width: image.width / 4, height: image.height / 2)))
        var bytes = [UInt8](repeating: 0, count: cell.width * cell.height * 4)
        bytes.withUnsafeMutableBytes { buffer in
            let context = CGContext(data: buffer.baseAddress, width: cell.width, height: cell.height, bitsPerComponent: 8, bytesPerRow: cell.width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)!
            context.draw(cell, in: CGRect(x: 0, y: 0, width: cell.width, height: cell.height))
        }
        var visible = 0, blue = 0, transparent = 0
        for i in stride(from: 0, to: bytes.count, by: 4) {
            if bytes[i+3] == 0 { transparent += 1 }
            if bytes[i+3] > 250 {
                visible += 1
                if Int(bytes[i+2]) > Int(bytes[i]) + 70 && Int(bytes[i+1]) > Int(bytes[i]) + 35 { blue += 1 }
            }
        }
        XCTAssertGreaterThan(visible, 1000); XCTAssertGreaterThan(transparent, 1000)
        XCTAssertEqual(blue, visible)
    }
    func testFireRecoveryIsDecodedAfterSpeedBoostEnds() throws {
        let frame = try ClassicBridge().fireRecoveryFrame(left: 100, right: 1300)
        XCTAssertEqual(frame.player.fireRecoveryRemaining, 0.45, accuracy: 0.000001)
        XCTAssertEqual(frame.player.burnUntil, 0)
        XCTAssertEqual(frame.player.vx, 0); XCTAssertEqual(frame.player.vy, 0)
    }
    @MainActor func testHUDRibbonGrowsWithLocalizedNumbersAndKeepsBrushTipsFixed() {
        for locale in ["en_US", "es_ES"] {
            for alignment in [SKLabelHorizontalAlignmentMode.left, .right] {
                let label = SKLabelNode(fontNamed: "AvenirNextCondensed-Heavy")
                label.fontSize = 22; label.verticalAlignmentMode = .center
                label.horizontalAlignmentMode = alignment
                label.position = CGPoint(x: alignment == .left ? 120 : 800, y: 615)
                let ribbon = HUDRibbon()
                var previousWidth: CGFloat = 0
                for value in [0, 999, 1_000_000, 9_007_199_254_740_991] {
                    label.text = value.formatted(.number.locale(Locale(identifier: locale)))
                    ribbon.fit(textFrame: label.frame)
                    XCTAssertTrue(ribbon.backingFrame.contains(label.frame))
                    XCTAssertGreaterThan(ribbon.backingFrame.width, previousWidth)
                    XCTAssertEqual(label.fontSize, 22)
                    XCTAssertEqual((ribbon.children.first as? SKSpriteNode)?.size.width, HUDRibbon.padding)
                    XCTAssertEqual((ribbon.children.last as? SKSpriteNode)?.size.width, HUDRibbon.padding)
                    previousWidth = ribbon.backingFrame.width
                }
                label.text = "0"; ribbon.fit(textFrame: label.frame)
                XCTAssertLessThan(ribbon.backingFrame.width, previousWidth)
            }
        }
    }
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
        XCTAssertEqual(Set(ApprovedOrbArt.regions.keys), Set(["nuke", "wave", "frost", "bubble", "lightning", "laser", "burn", "vortex", "boomerang", "spikes", "missiles"]))
        for power in ApprovedOrbArt.regions.keys {
            let node = try XCTUnwrap(InkArt.node(style: power) as? SKCropNode)
            XCTAssertNotNil(node.maskNode)
            XCTAssertEqual(node.children.count, 1)
            let art = try XCTUnwrap(node.children.first as? SKSpriteNode)
            let crop = try XCTUnwrap(ApprovedOrbArt.regions[power]).crop
            XCTAssertEqual(try XCTUnwrap(art.texture).size(), CGSize(width: crop[2], height: crop[3]))
            XCTAssertEqual(art.position, .zero)
            XCTAssertEqual(art.anchorPoint, CGPoint(x: 0.5, y: 0.5))
            XCTAssertEqual(art.colorBlendFactor, 0)
            XCTAssertTrue(art.children.isEmpty)
            XCTAssertGreaterThan(art.size.width * 56 / 42, 50)
            XCTAssertLessThan(art.size.width * 56 / 42, 60)
        }
        XCTAssertNil(ApprovedOrbArt.node(for: "unknown-power"))
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
        XCTAssertEqual(frame.fields.count, 2); XCTAssertEqual(frame.pickups.count, 11)
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
        XCTAssertEqual(Set(InkArt.orbColors.values).count, 11)
    }
    func testNewAreaEffectsHaveCompleteBoundariesAndDeterministicPauseState() throws {
        for kind in ["frost", "blast"] { for theme in VisualTheme.allCases { for reduced in [false, true] {
            let radius: CGFloat = kind == "frost" ? 205 : 155
            let effect = ClassicAreaEffect(kind: kind, radius: radius, theme: theme, reduced: reduced)
            let wash = try XCTUnwrap(effect.childNode(withName: "//complete-area") as? SKShapeNode)
            let path = try XCTUnwrap(wash.path)
            for i in 0..<36 {
                let angle = CGFloat(i) * .pi / 18
                XCTAssertTrue(path.contains(CGPoint(x: cos(angle)*radius*0.9, y: sin(angle)*radius*0.9)))
            }
            effect.update(remaining: 0.7, duration: 1.2)
            let bounds = effect.calculateAccumulatedFrame(), count = effect.children.count
            var allNodes: [SKNode] = []
            effect.enumerateChildNodes(withName: "//*") { node, _ in allNodes.append(node) }
            XCTAssertLessThan(allNodes.count, 240, "Per-field particle budget remains bounded")
            let particle = try XCTUnwrap(effect.childNode(withName: kind == "frost" ? "//ice-fragment" : "//ember"))
            let position = particle.position
            effect.update(remaining: 0.7, duration: 1.2)
            XCTAssertEqual(effect.calculateAccumulatedFrame(), bounds)
            XCTAssertEqual(effect.children.count, count)
            XCTAssertLessThan(bounds.width, radius * 2.1)
            XCTAssertLessThan(bounds.height, radius * 2.1)
            XCTAssertFalse(effect.hasActions(), "Simulation time controls both pause and effect expiry")
            effect.update(remaining: 0.5, duration: 1.2)
            XCTAssertNotEqual(particle.position, position, "Approved fragments move independently through time")
            effect.update(remaining: 0, duration: 1.2); XCTAssertEqual(effect.alpha, 0)
        } } }
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
