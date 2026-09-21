import SpriteKit

/// Charge progress is still driven exclusively by the existing simulation clock.
final class ThemedCharge: SKNode {
    enum Kind { case fire, wave, boomerang }
    private let kind: Kind, theme: VisualTheme
    private var original: SKNode?
    private let stroke = SKShapeNode(), mark = SKNode()
    private var flecks: [SKSpriteNode] = []
    init(_ kind: Kind, theme: VisualTheme) {
        self.kind = kind; self.theme = theme; super.init()
        if theme == .classic {
            switch kind {
            case .fire: original = ClassicFireCharge()
            case .wave: original = ClassicWaveCharge()
            case .boomerang: original = ClassicBoomerangCharge()
            }
            if let original = original { addChild(original) }
        } else {
            if kind != .fire { position.x = kind == .wave ? 28 : 38 }
            stroke.strokeColor = kind == .wave ? InkArt.blue : InkArt.gold
            stroke.lineWidth = 3; stroke.lineCap = .round; addChild(stroke)
            let art = InkArt.sprite(kind == .wave ? 3 : (kind == .fire ? 4 : 7), size: 35)
            if kind == .fire { art.position.x = 34 }
            mark.addChild(art); addChild(mark)
            for _ in 0..<7 {
                let fleck = InkArt.sprite(6, size: 7)
                fleck.color = kind == .wave ? InkArt.blue : InkArt.gold; fleck.colorBlendFactor = 1
                addChild(fleck); flecks.append(fleck)
            }
        }
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(progress: Double, active: Bool, reduced: Bool) {
        isHidden = !active
        if let original = original {
            (original as? ClassicFireCharge)?.update(progress: progress, active: active, reduced: reduced)
            (original as? ClassicWaveCharge)?.update(progress: progress, active: active, reduced: reduced)
            (original as? ClassicBoomerangCharge)?.update(progress: progress, active: active, reduced: reduced)
            return
        }
        guard active else { return }
        let p = CGFloat(max(0, min(1, progress))), radius: CGFloat = kind == .fire ? 32 : 20
        stroke.path = InkArt.ringPath(radius: radius, fraction: p, phase: -.pi / 2)
        mark.setScale(0.35 + p * 0.65); mark.alpha = 0.45 + p * 0.55
        mark.zRotation = kind == .boomerang && !reduced ? p * .pi * 2 : 0
        for (i, fleck) in flecks.enumerated() {
            fleck.isHidden = reduced
            let t = (p * 1.7 + CGFloat(i) / 7).truncatingRemainder(dividingBy: 1)
            let angle = CGFloat(i) * .pi * 2 / 7 + p, r = radius + 18 - t * 30
            fleck.position = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            fleck.zRotation = angle; fleck.alpha = sin(t * .pi)
        }
    }
}
