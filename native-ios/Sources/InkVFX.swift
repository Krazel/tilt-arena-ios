import SpriteKit

/// Matte ink, paper shards and broken brush rings. No additive bloom.
final class InkVFX {
    let layer: SKNode
    init(layer: SKNode) { self.layer = layer }
    func show(_ event: ClassicFrame.Event, reduced: Bool) {
        guard let x = event.x, let y = event.y else { return }
        let kinds = ["blast", "freeze", "death", "wave", "pickup", "burnLaunch", "electricPulse", "boomerangLaunch", "boomerangBounce", "boomerangCatch", "kill", "spawnPickup", "lightning", "combo"]
        guard kinds.contains(event.kind) else { return }
        if layer.children.count >= 40 {
            if event.kind == "kill" { return }
            (layer.children.first(where: { $0.name == "spark" }) ?? layer.children.first)?.removeFromParent()
        }
        let root = SKNode(); root.position = CGPoint(x: x, y: y)
        root.name = event.kind == "kill" ? "spark" : "weapon"; layer.addChild(root)
        root.run(.sequence([.wait(forDuration: 1.15), .removeFromParent()]))
        let color = InkArt.color(for: event.power ?? event.kind)
        switch event.kind {
        case "blast", "death":
            root.addChild(InkExplosion(radius: CGFloat(event.radius ?? 95), color: event.kind == "death" ? InkArt.red : color, reduced: reduced))
        case "freeze":
            let radius = CGFloat(event.radius ?? 205)
            ring(root, radius: radius, color: InkArt.blue, reduced: reduced)
            let ice = SKNode(); root.addChild(ice)
            // Preserve the readable crystalline silhouette, now printed in blue ink.
            for i in 0..<12 {
                let a = CGFloat(i) * .pi / 6, r = radius * (i % 2 == 0 ? 1 : 0.75)
                let p = CGMutablePath(); p.move(to: .zero)
                p.addLine(to: CGPoint(x: cos(a - 0.14) * r * 0.3, y: sin(a - 0.14) * r * 0.3))
                p.addLine(to: CGPoint(x: cos(a) * r, y: sin(a) * r))
                p.addLine(to: CGPoint(x: cos(a + 0.12) * r * 0.45, y: sin(a + 0.12) * r * 0.45)); p.closeSubpath()
                let shard = SKShapeNode(path: p); shard.fillColor = i % 2 == 0 ? InkArt.blue : InkArt.paper
                shard.strokeColor = InkArt.paper; shard.lineWidth = 1; shard.alpha = reduced ? 0.2 : 0.65; ice.addChild(shard)
            }
            ice.setScale(reduced ? 1 : 0.05)
            ice.run(.sequence([.scale(to: 1, duration: reduced ? 0 : 0.18), .wait(forDuration: 0.08), .fadeOut(withDuration: 0.4), .removeFromParent()]))
            flecks(root, color: InkArt.paper, count: reduced ? 3 : 18, radius: radius, reduced: reduced)
        case "lightning":
            guard let tx = event.toX, let ty = event.toY else { return }
            let dx = tx - x, dy = ty - y, d = max(1, hypot(dx, dy))
            let p = CGMutablePath(); p.move(to: .zero)
            for i in 1..<9 {
                let t = Double(i) / 9, j = (i % 2 == 0 ? 8.0 : -8.0)
                p.addLine(to: CGPoint(x: dx * t - dy / d * j, y: dy * t + dx / d * j))
            }
            p.addLine(to: CGPoint(x: dx, y: dy))
            for (width, tint) in [(CGFloat(7), InkArt.blue), (CGFloat(2), InkArt.paper)] {
                let bolt = SKShapeNode(path: p); bolt.strokeColor = tint; bolt.lineWidth = width; root.addChild(bolt)
            }
            root.run(.sequence([.fadeOut(withDuration: 0.28), .removeFromParent()]))
        case "electricPulse": ring(root, radius: CGFloat(event.radius ?? 220), color: InkArt.blue, reduced: reduced, opacity: 0.35)
        case "combo":
            let label = SKLabelNode(fontNamed: "AvenirNextCondensed-Heavy")
            label.text = "+\((event.bonus ?? 0).formatted())"; label.fontSize = 24; label.fontColor = InkArt.paper
            root.addChild(label); root.run(.sequence([.group([.moveBy(x: 0, y: reduced ? 0 : 22, duration: 0.7), .fadeOut(withDuration: 0.7)]), .removeFromParent()]))
        case "kill": flecks(root, color: InkArt.red, count: reduced ? 2 : 6, radius: 35, reduced: reduced)
        default:
            let radius: CGFloat = event.kind == "spawnPickup" ? 38 : 50
            ring(root, radius: radius, color: color, reduced: reduced)
            flecks(root, color: color, count: reduced ? 2 : 8, radius: radius, reduced: reduced)
        }
    }
    private func ring(_ root: SKNode, radius: CGFloat, color: UIColor, reduced: Bool, opacity: CGFloat = 0.8) {
        let ring = InkArt.brushRing(radius: radius, color: color, width: reduced ? 2 : 3)
        ring.alpha = opacity; ring.setScale(reduced ? 1 : 0.2); root.addChild(ring)
        ring.run(.sequence([.group([.scale(to: 1, duration: reduced ? 0 : 0.3), .fadeOut(withDuration: 0.5)]), .removeFromParent()]))
    }
    private func flecks(_ root: SKNode, color: UIColor, count: Int, radius: CGFloat, reduced: Bool) {
        for i in 0..<count {
            let a = CGFloat(i) * 2.39996, r = radius * (0.45 + CGFloat(i % 4) * 0.18)
            let fleck = InkArt.sprite(6, size: CGFloat(9 + i % 3 * 4))
            fleck.color = color; fleck.colorBlendFactor = 1; fleck.zRotation = a
            root.addChild(fleck)
            let target = CGPoint(x: cos(a) * r, y: sin(a) * r)
            if reduced { fleck.position = target }
            fleck.run(.sequence([.group([.move(to: target, duration: reduced ? 0 : 0.38), .fadeOut(withDuration: 0.5)]), .removeFromParent()]))
        }
    }
    func attachTrail(to node: SKNode, reduced: Bool, boomerang: Bool) {
        guard !reduced else { return }
        let emitter = SKEmitterNode(); emitter.particleTexture = InkArt.cells[6]
        emitter.particleColor = boomerang ? InkArt.gold : InkArt.paper
        emitter.particleColorBlendFactor = 1; emitter.particleBlendMode = .alpha
        emitter.particleBirthRate = 35; emitter.particleLifetime = 0.22
        emitter.particleScale = 0.022; emitter.particleScaleSpeed = -0.06
        emitter.particleAlpha = 0.7; emitter.particleAlphaSpeed = -3
        emitter.targetNode = layer; node.addChild(emitter)
    }
}

final class InkExplosion: SKNode {
    private let front: SKShapeNode, echo: SKShapeNode, center: SKSpriteNode
    private var marks: [SKSpriteNode] = []
    private let radius: CGFloat, reduced: Bool
    init(radius: CGFloat, color: UIColor, reduced: Bool) {
        self.radius = radius; self.reduced = reduced
        front = InkArt.brushRing(radius: radius, color: InkArt.paper, width: 5)
        echo = InkArt.brushRing(radius: radius * 0.82, color: color, width: 8)
        center = InkArt.sprite(6, size: radius * 1.6)
        super.init(); addChild(front); addChild(echo); addChild(center)
        for i in 0..<(reduced ? 4 : 14) {
            let mark = InkArt.sprite(6, size: CGFloat(18 + i % 4 * 9))
            mark.color = i % 3 == 0 ? InkArt.paper : color; mark.colorBlendFactor = 1
            addChild(mark); marks.append(mark)
        }
        update(elapsed: 0)
        run(.sequence([.customAction(withDuration: 0.7) { node, t in (node as? InkExplosion)?.update(elapsed: Double(t)) }, .removeFromParent()]))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(elapsed: Double) {
        let t = CGFloat(max(0, elapsed)), p = min(1, t / 0.7)
        let spread = 1 - pow(1 - min(1, t / 0.26), 3)
        front.setScale(reduced ? 1 : 0.1 + spread * 0.9); front.alpha = max(0, 1 - t / 0.55) * (reduced ? 0.35 : 0.9)
        echo.setScale(reduced ? 1 : 0.1 + spread * 0.9); echo.alpha = max(0, 1 - t / 0.65) * 0.7
        center.setScale(reduced ? 0.65 : 0.1 + spread); center.alpha = max(0, 1 - t / 0.3) * (reduced ? 0.2 : 0.9)
        for (i, mark) in marks.enumerated() {
            let a = CGFloat(i) * 2.39996, r = radius * (reduced ? 0.7 : 0.15 + spread * (0.55 + CGFloat(i % 3) * 0.16))
            mark.position = CGPoint(x: cos(a) * r, y: sin(a) * r); mark.zRotation = a
            mark.alpha = max(0, 1 - p); mark.setScale(1 - p * 0.4)
        }
    }
}
