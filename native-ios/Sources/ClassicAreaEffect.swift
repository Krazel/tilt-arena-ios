import SpriteKit

/// Persistent weapon art follows simulation time, including pause and skin changes.
final class ClassicAreaEffect: SKNode {
    private let kind: String, reduced: Bool
    private let body = SKNode()
    private var inkBlast: InkExplosion?
    private var classicBlast: ClassicExplosion?
    init(kind: String, radius: CGFloat, theme: VisualTheme, reduced: Bool) {
        self.kind = kind; self.reduced = reduced
        super.init(); addChild(body)
        let ink = theme == .inkTide
        let tint = kind == "frost" ? (ink ? InkArt.blue : UIColor(hex: "70dce9")) : (ink ? InkArt.gold : UIColor(hex: "ffb52a"))
        let rim = ink ? InkArt.brushRing(radius: radius, color: tint, width: 3) : SKShapeNode(circleOfRadius: radius)
        rim.strokeColor = tint; rim.lineWidth = 3
        rim.fillColor = tint.withAlphaComponent(kind == "frost" ? 0.045 : 0.07)
        rim.alpha = 0.5; body.addChild(rim)
        if kind == "blast" {
            if ink {
                let blast = InkExplosion(radius: radius, color: tint, reduced: reduced)
                blast.removeAllActions(); body.addChild(blast); inkBlast = blast
            } else {
                let blast = ClassicExplosion(radius: radius, color: tint, reduced: reduced)
                blast.removeAllActions(); body.addChild(blast); classicBlast = blast
            }
        } else {
            for i in 0..<12 {
                let a = CGFloat(i) * .pi / 6, r = radius * (i % 2 == 0 ? 1 : 0.75)
                let p = CGMutablePath(); p.move(to: .zero)
                p.addLine(to: CGPoint(x: cos(a - 0.14) * r * 0.3, y: sin(a - 0.14) * r * 0.3))
                p.addLine(to: CGPoint(x: cos(a) * r, y: sin(a) * r))
                p.addLine(to: CGPoint(x: cos(a + 0.12) * r * 0.45, y: sin(a + 0.12) * r * 0.45)); p.closeSubpath()
                let shard = SKShapeNode(path: p)
                shard.fillColor = i % 2 == 0 ? tint : (ink ? InkArt.paper : .white)
                shard.strokeColor = ink ? InkArt.paper : .white; shard.lineWidth = 1
                shard.alpha = reduced ? 0.22 : 0.55; body.addChild(shard)
            }
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(remaining: Double, duration: Double) {
        let elapsed = max(0, duration - remaining)
        alpha = CGFloat(min(1, max(0, remaining) / 0.25))
        if kind == "frost" {
            body.setScale(reduced ? 1 : CGFloat(0.05 + 0.95 * min(1, elapsed / 0.18)))
        } else {
            // Fast detonation, then a sustained rolling bloom before the final fade.
            let visualTime = min(0.7, elapsed < 0.22 ? elapsed : 0.22 + (elapsed - 0.22) * 0.32)
            inkBlast?.update(elapsed: visualTime); classicBlast?.update(elapsed: visualTime)
        }
    }
}
