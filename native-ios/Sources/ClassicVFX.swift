import SpriteKit

/// Time-based effects, with a hard node/particle budget and a reduced-motion mode.
final class ClassicVFX {
    let layer: SKNode
    init(layer: SKNode) { self.layer = layer }
    func show(_ event: ClassicFrame.Event, reduced: Bool) {
        guard let x = event.x, let y = event.y, layer.children.count < 48 else { return }
        let point = CGPoint(x: x, y: y), color = UIColor(hex: event.color ?? "f3ffcd")
        switch event.kind {
        case "kill":
            burst(at: point, color: color, count: reduced ? 3 : 7, speed: 85, duration: 0.28)
        case "blast", "freeze", "death":
            let radius = event.radius ?? 100
            ring(at: point, color: color, radius: radius, delay: 0, reduced: reduced)
            if !reduced { ring(at: point, color: color, radius: radius * 0.88, delay: 0.08, reduced: false) }
            burst(at: point, color: color, count: reduced ? 8 : 32, speed: event.kind == "freeze" ? 150 : 260, duration: 0.55)
            if event.kind == "freeze" && !reduced { ice(at: point, color: color) }
        case "pickup":
            ring(at: point, color: color, radius: 38, delay: 0, reduced: reduced)
            burst(at: point, color: color, count: reduced ? 4 : 14, speed: 95, duration: 0.4)
        case "lightning":
            guard let tx = event.toX, let ty = event.toY else { return }
            let path = CGMutablePath(); path.move(to: point)
            let dx = tx - x, dy = ty - y, distance = max(1, hypot(dx, dy))
            for index in 1..<6 {
                let t = Double(index) / 6, jitter = reduced ? 0 : (index % 2 == 0 ? 6.0 : -6.0)
                path.addLine(to: CGPoint(x: x + dx * t - dy / distance * jitter, y: y + dy * t + dx / distance * jitter))
            }
            path.addLine(to: CGPoint(x: tx, y: ty))
            let bolt = SKShapeNode(path: path); bolt.strokeColor = .white; bolt.lineWidth = 2
            bolt.glowWidth = reduced ? 0 : 4; layer.addChild(bolt)
            bolt.run(.sequence([.fadeOut(withDuration: 0.2), .removeFromParent()]))
        case "combo":
            guard let bonus = event.bonus else { return }
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "+\(bonus.formatted())"; label.fontSize = 24; label.fontColor = UIColor(hex: "e1ff85")
            label.position = point; layer.addChild(label)
            label.run(.sequence([.group([.moveBy(x: 0, y: reduced ? 0 : 22, duration: 0.7), .fadeOut(withDuration: 0.7)]), .removeFromParent()]))
        default: break
        }
    }
    private func ring(at point: CGPoint, color: UIColor, radius: Double, delay: Double, reduced: Bool) {
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.position = point; ring.strokeColor = color; ring.lineWidth = 3; ring.glowWidth = reduced ? 0 : 4
        ring.fillColor = color.withAlphaComponent(0.025); ring.setScale(reduced ? 1 : 0.05)
        ring.alpha = 0; layer.addChild(ring)
        ring.run(.sequence([.wait(forDuration: delay), .fadeAlpha(to: 0.85, duration: 0.02),
                            .group([.scale(to: 1, duration: 0.35), .fadeOut(withDuration: 0.4)]), .removeFromParent()]))
    }
    private func burst(at point: CGPoint, color: UIColor, count: Int, speed: CGFloat, duration: Double) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ClassicArt.spark
        emitter.particleColor = color; emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = .add
        emitter.numParticlesToEmit = count; emitter.particleBirthRate = 800
        emitter.particleLifetime = duration; emitter.particleLifetimeRange = 0.12
        emitter.emissionAngleRange = .pi * 2; emitter.particleSpeed = speed; emitter.particleSpeedRange = speed * 0.7
        emitter.particleScale = 0.055; emitter.particleScaleRange = 0.03; emitter.particleScaleSpeed = -0.05
        emitter.particleAlphaSpeed = -1 / duration
        emitter.position = point; layer.addChild(emitter)
        emitter.run(.sequence([.wait(forDuration: duration + 0.3), .removeFromParent()]))
    }
    private func ice(at point: CGPoint, color: UIColor) {
        for index in 0..<10 {
            let shard = SKShapeNode(path: ClassicArt.star(radius: 5, inner: 1.5, points: 3))
            shard.position = point; shard.fillColor = color; shard.strokeColor = .white; shard.lineWidth = 0.6
            let angle = CGFloat(index) * .pi / 5
            layer.addChild(shard)
            shard.run(.sequence([.group([.moveBy(x: cos(angle) * 130, y: sin(angle) * 130, duration: 0.5),
                                         .rotate(byAngle: 2, duration: 0.5), .fadeOut(withDuration: 0.5)]), .removeFromParent()]))
        }
    }
    func attachMissileTrail(to node: SKNode, reduced: Bool) {
        guard !reduced else { return }
        let emitter = SKEmitterNode(); emitter.particleTexture = ClassicArt.spark
        emitter.particleColor = UIColor(hex: "ffc056"); emitter.particleColorBlendFactor = 1; emitter.particleBlendMode = .add
        emitter.particleBirthRate = 28; emitter.particleLifetime = 0.22
        emitter.particleScale = 0.045; emitter.particleScaleSpeed = -0.13; emitter.particleAlphaSpeed = -4
        emitter.position = CGPoint(x: -8, y: 0); emitter.targetNode = layer
        node.addChild(emitter)
    }
}
