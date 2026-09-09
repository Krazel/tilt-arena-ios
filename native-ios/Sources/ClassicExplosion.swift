import SpriteKit

/// Short layered detonation: hot core, rolling bloom, shock fronts and fragments.
final class ClassicExplosion: SKNode {
    private let core = SKNode(), bloom = SKNode()
    private let front: SKShapeNode, echo: SKShapeNode
    private var fragments: [SKShapeNode] = []
    private let radius: CGFloat, reduced: Bool

    init(radius: CGFloat, color: UIColor, reduced: Bool) {
        self.radius = radius; self.reduced = reduced
        front = SKShapeNode(circleOfRadius: radius)
        echo = SKShapeNode(circleOfRadius: radius * 0.77)
        super.init()
        front.name = "shock-front"; core.name = "hot-core"
        addChild(bloom); addChild(core); addChild(front); addChild(echo)
        front.strokeColor = UIColor(hex: "fff5ce"); front.fillColor = .clear
        front.lineWidth = max(2, radius * 0.045); front.glowWidth = reduced ? 0 : 2
        echo.strokeColor = color; echo.fillColor = .clear; echo.lineWidth = max(2, radius * 0.06)
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let puff = SKShapeNode(circleOfRadius: radius * (i % 2 == 0 ? 0.24 : 0.2))
            puff.position = CGPoint(x: cos(angle) * radius * 0.29, y: sin(angle) * radius * 0.29)
            puff.fillColor = color.withAlphaComponent(0.65); puff.strokeColor = color
            puff.lineWidth = 1.5; bloom.addChild(puff)
        }
        let corona = SKShapeNode(path: ClassicArt.star(radius: radius * 0.52, inner: radius * 0.32, points: 16))
        corona.fillColor = UIColor(hex: "ffe4a1"); corona.strokeColor = color; corona.lineWidth = 2
        core.addChild(corona)
        let center = SKShapeNode(circleOfRadius: radius * 0.28)
        center.fillColor = UIColor(hex: "fffde8"); center.strokeColor = .clear; core.addChild(center)
        if !reduced {
            for i in 0..<12 {
                let shard = SKShapeNode(path: ClassicArt.star(radius: max(3, radius * 0.045), inner: max(1, radius * 0.015), points: 3))
                shard.name = "fragment"
                shard.fillColor = i % 3 == 0 ? UIColor(hex: "fff4cf") : color
                shard.strokeColor = UIColor(hex: "fff4cf"); shard.lineWidth = 1
                fragments.append(shard); addChild(shard)
            }
        }
        update(elapsed: 0)
        run(.sequence([.customAction(withDuration: 0.7) { node, elapsed in
            (node as? ClassicExplosion)?.update(elapsed: Double(elapsed))
        }, .removeFromParent()]))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    func update(elapsed: Double) {
        let t = max(0, elapsed), p = min(1, t / 0.7)
        let spread = CGFloat(1 - pow(1 - min(1, t / 0.25), 3))
        front.setScale(reduced ? 1 : 0.12 + spread * 0.88)
        front.alpha = CGFloat(max(0, 1 - t / 0.55)) * (reduced ? 0.45 : 0.95)
        let delayed = CGFloat(1 - pow(1 - min(1, max(0, t - 0.04) / 0.3), 3))
        echo.setScale(reduced ? 1 : 0.1 + delayed * 0.9)
        echo.alpha = CGFloat(max(0, 1 - t / 0.65)) * (reduced ? 0.25 : 0.7)
        core.setScale(reduced ? 0.7 : 0.15 + spread * 0.85)
        core.alpha = CGFloat(max(0, 1 - max(0, t - 0.09) / 0.25)) * (reduced ? 0.35 : 1)
        bloom.setScale(reduced ? 1 : 0.1 + spread * 1.5)
        bloom.alpha = CGFloat(max(0, 1 - t / 0.58)) * (reduced ? 0.18 : 0.8)
        for (i, shard) in fragments.enumerated() {
            let angle = CGFloat(i) * .pi / 6 + 0.12
            let travel = radius * (0.3 + CGFloat(p) * (i % 2 == 0 ? 0.85 : 0.65))
            shard.position = CGPoint(x: cos(angle) * travel, y: sin(angle) * travel)
            shard.zRotation = angle + CGFloat(t) * 4
            shard.alpha = CGFloat(max(0, 1 - t / 0.6))
            shard.setScale(CGFloat(1 - p * 0.7))
        }
    }
}
