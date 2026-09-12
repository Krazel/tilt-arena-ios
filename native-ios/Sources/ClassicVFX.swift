import SpriteKit

/// Each transient owns one bounded root; important weapon effects displace old sparks.
final class ClassicVFX {
    let layer: SKNode
    init(layer: SKNode) { self.layer = layer }
    private static let glow: SKTexture = {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 128, height: 128))
        return SKTexture(image: renderer.image { context in
            let colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.35).cgColor,
                          UIColor.white.withAlphaComponent(0).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.28, 1])!
            context.cgContext.drawRadialGradient(gradient, startCenter: CGPoint(x: 64, y: 64), startRadius: 0,
                endCenter: CGPoint(x: 64, y: 64), endRadius: 64, options: [])
        })
    }()
    func show(_ event: ClassicFrame.Event, reduced: Bool) {
        guard let x = event.x, let y = event.y else { return }
        let important = ["blast", "freeze", "death", "wave", "pickup", "burnLaunch", "electricPulse", "boomerangLaunch", "boomerangBounce", "boomerangCatch"].contains(event.kind)
        guard important || ["kill", "spawnPickup", "lightning", "combo"].contains(event.kind) else { return }
        if layer.children.count >= 40 {
            guard important else { return }
            (layer.children.first(where: { $0.name == "spark" }) ?? layer.children.first)?.removeFromParent()
        }
        let root = SKNode(); root.position = CGPoint(x: x, y: y)
        root.name = important ? "weapon" : "spark"; layer.addChild(root)
        let color = UIColor(hex: event.color ?? "f3ffcd")
        root.run(.sequence([.wait(forDuration: 1.15), .removeFromParent()]))
        switch event.kind {
        case "electricPulse":
            let radius = event.radius ?? 220
            let rim = SKShapeNode(circleOfRadius: radius)
            rim.strokeColor = UIColor(hex: "c6f5ff"); rim.lineWidth = reduced ? 1 : 2
            rim.alpha = 0.35; root.addChild(rim)
            flash(on: root, color: UIColor(hex: "c6f5ff"), diameter: 90, duration: 0.24, reduced: reduced)
            root.run(.sequence([.fadeOut(withDuration: 0.35), .removeFromParent()]))
        case "boomerangLaunch", "boomerangBounce", "boomerangCatch":
            ring(on: root, color: color, radius: event.kind == "boomerangBounce" ? 38 : 26, reduced: reduced)
            burst(on: root, color: color, count: reduced ? 2 : 8, speed: 75, duration: 0.25)
        case "burnLaunch":
            flash(on: root, color: UIColor(hex: "ffb444"), diameter: 95, duration: 0.2, reduced: reduced)
            ring(on: root, color: UIColor(hex: "ffe3a0"), radius: 45, reduced: reduced)
            burst(on: root, color: color, count: reduced ? 3 : 14, speed: 150, duration: 0.3)
        case "kill":
            flash(on: root, color: color, diameter: 36, duration: 0.18, reduced: reduced)
            burst(on: root, color: color, count: reduced ? 2 : 6, speed: 105, duration: 0.3)
        case "freeze":
            let radius = event.radius ?? 205
            flash(on: root, color: color, diameter: radius * 2, duration: 0.55, reduced: reduced)
            if reduced { ring(on: root, color: color, radius: radius, reduced: true) }
            else { crystal(on: root, radius: radius, color: color) }
            burst(on: root, color: .white, count: reduced ? 5 : 24, speed: 210, duration: 0.6)
        case "blast":
            root.addChild(ClassicExplosion(radius: CGFloat(event.radius ?? 155), color: color, reduced: reduced))
            root.run(.sequence([.wait(forDuration: 0.75), .removeFromParent()]))
        case "death":
            let radius = event.radius ?? 95
            flash(on: root, color: color, diameter: radius * 2.15, duration: 0.5, reduced: reduced)
            ring(on: root, color: color, radius: radius, reduced: reduced)
            if !reduced {
                ring(on: root, color: .white, radius: radius * 0.72, reduced: false, delay: 0.06)
                spokes(on: root, color: color, radius: radius)
            }
            burst(on: root, color: color, count: reduced ? 6 : 28, speed: CGFloat(radius * 1.5), duration: 0.55)
        case "pickup", "spawnPickup":
            let arriving = event.kind == "spawnPickup"
            ring(on: root, color: color, radius: arriving ? 42 : 52, reduced: reduced)
            flash(on: root, color: color, diameter: arriving ? 60 : 90, duration: 0.35, reduced: reduced)
            if !arriving { burst(on: root, color: color, count: reduced ? 3 : 12, speed: 100, duration: 0.4) }
        case "wave":
            root.zRotation = CGFloat(event.angle ?? 0)
            flash(on: root, color: color, diameter: 95, duration: 0.25, reduced: reduced)
            burst(on: root, color: color, count: reduced ? 3 : 12, speed: 170, duration: 0.35)
        case "lightning":
            guard let tx = event.toX, let ty = event.toY else { root.removeFromParent(); return }
            let dx = tx - x, dy = ty - y, distance = max(1, hypot(dx, dy))
            let path = CGMutablePath(); path.move(to: .zero)
            for i in 1..<8 {
                let t = Double(i) / 8, jitter = reduced ? 0 : (i % 2 == 0 ? 8.0 : -8.0)
                path.addLine(to: CGPoint(x: dx * t - dy / distance * jitter, y: dy * t + dx / distance * jitter))
            }
            path.addLine(to: CGPoint(x: dx, y: dy))
            for (width, tint) in [(CGFloat(8), color.withAlphaComponent(0.4)), (CGFloat(2.8), UIColor.white)] {
                let bolt = SKShapeNode(path: path); bolt.strokeColor = tint; bolt.lineWidth = reduced ? width * 0.6 : width
                bolt.glowWidth = reduced ? 0 : 2; root.addChild(bolt)
            }
            root.run(.sequence([.fadeOut(withDuration: 0.28), .removeFromParent()]))
        case "combo":
            guard let bonus = event.bonus else { root.removeFromParent(); return }
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = "+\(bonus.formatted())"; label.fontSize = 24; label.fontColor = UIColor(hex: "e1ff85")
            root.addChild(label)
            root.run(.sequence([.group([.moveBy(x: 0, y: reduced ? 0 : 22, duration: 0.7), .fadeOut(withDuration: 0.7)]), .removeFromParent()]))
        default: break
        }
    }
    private func flash(on root: SKNode, color: UIColor, diameter: Double, duration: Double, reduced: Bool) {
        let node = SKSpriteNode(texture: Self.glow); node.size = CGSize(width: diameter, height: diameter)
        node.color = color; node.colorBlendFactor = 1; node.blendMode = .add
        node.alpha = reduced ? 0.24 : 0.85; node.setScale(reduced ? 1 : 0.22); root.addChild(node)
        node.run(.sequence([.group([.scale(to: 1, duration: duration * 0.55), .fadeOut(withDuration: duration)]), .removeFromParent()]))
    }
    private func ring(on root: SKNode, color: UIColor, radius: Double, reduced: Bool, delay: Double = 0) {
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.strokeColor = color; ring.lineWidth = reduced ? 2 : 4; ring.glowWidth = reduced ? 0 : 3
        ring.fillColor = color.withAlphaComponent(reduced ? 0.025 : 0.09)
        ring.setScale(reduced ? 1 : 0.08); ring.alpha = 0; root.addChild(ring)
        let expand = SKAction.scale(to: 1, duration: 0.34); expand.timingMode = .easeOut
        ring.run(.sequence([.wait(forDuration: delay), .fadeAlpha(to: 0.8, duration: 0.02),
            .group([expand, .fadeOut(withDuration: 0.5)]), .removeFromParent()]))
    }
    private func crystal(on root: SKNode, radius: Double, color: UIColor) {
        let ice = SKNode(); root.addChild(ice)
        let silhouette = SKShapeNode(path: ClassicArt.star(radius: radius, inner: radius * 0.39, points: 12))
        silhouette.fillColor = color.withAlphaComponent(0.48); silhouette.strokeColor = UIColor(hex: "e8ffff")
        silhouette.lineWidth = 2.5; ice.addChild(silhouette)
        for i in 0..<12 {
            let a = Double(i) * .pi / 6
            let r = radius * (i % 2 == 0 ? 0.98 : 0.74)
            let path = CGMutablePath(); path.move(to: .zero)
            path.addLine(to: CGPoint(x: cos(a - 0.16) * r * 0.32, y: sin(a - 0.16) * r * 0.32))
            path.addLine(to: CGPoint(x: cos(a) * r, y: sin(a) * r))
            path.addLine(to: CGPoint(x: cos(a + 0.2) * r * 0.46, y: sin(a + 0.2) * r * 0.46)); path.closeSubpath()
            let shard = SKShapeNode(path: path); shard.fillColor = UIColor(hex: i % 2 == 0 ? "e4ffff" : "71bce9").withAlphaComponent(0.8)
            shard.strokeColor = .white; shard.lineWidth = 1; ice.addChild(shard)
        }
        ice.setScale(0.08)
        let expand = SKAction.scale(to: 1, duration: 0.18); expand.timingMode = .easeOut
        ice.run(.sequence([expand, .wait(forDuration: 0.08), .group([.scale(to: 1.03, duration: 0.4), .fadeOut(withDuration: 0.4)]), .removeFromParent()]))
    }
    private func spokes(on root: SKNode, color: UIColor, radius: Double) {
        let path = CGMutablePath()
        for i in 0..<14 {
            let a = Double(i) * .pi / 7
            path.move(to: CGPoint(x: cos(a) * radius * 0.2, y: sin(a) * radius * 0.2))
            path.addLine(to: CGPoint(x: cos(a) * radius * 0.88, y: sin(a) * radius * 0.88))
        }
        let rays = SKShapeNode(path: path); rays.strokeColor = color.withAlphaComponent(0.75); rays.lineWidth = 2
        root.addChild(rays); rays.setScale(0.3)
        rays.run(.sequence([.group([.scale(to: 1, duration: 0.28), .fadeOut(withDuration: 0.3)]), .removeFromParent()]))
    }
    private func burst(on root: SKNode, color: UIColor, count: Int, speed: CGFloat, duration: Double) {
        let emitter = SKEmitterNode(); emitter.particleTexture = ClassicArt.spark
        emitter.particleColor = color; emitter.particleColorBlendFactor = 1; emitter.particleBlendMode = .add
        emitter.numParticlesToEmit = count; emitter.particleBirthRate = 800
        emitter.particleLifetime = duration; emitter.particleLifetimeRange = 0.1
        emitter.emissionAngleRange = .pi * 2; emitter.particleSpeed = speed; emitter.particleSpeedRange = speed * 0.5
        emitter.particleScale = 0.075; emitter.particleScaleRange = 0.025; emitter.particleScaleSpeed = -0.07
        emitter.particleAlphaSpeed = -1 / duration; root.addChild(emitter)
    }
    func attachMissileTrail(to node: SKNode, reduced: Bool) {
        guard !reduced else { return }
        let emitter = SKEmitterNode(); emitter.particleTexture = Self.glow
        emitter.particleColor = UIColor(hex: "ffd15a"); emitter.particleColorBlendFactor = 1; emitter.particleBlendMode = .add
        emitter.particleBirthRate = 70; emitter.particleLifetime = 0.32
        emitter.particleScale = 0.065; emitter.particleScaleSpeed = -0.17; emitter.particleAlphaSpeed = -2.8
        emitter.position = CGPoint(x: -8, y: 0); emitter.targetNode = layer; node.addChild(emitter)
    }
    func attachBoomerangTrail(to node: SKNode, reduced: Bool) {
        guard !reduced else { return }
        let emitter = SKEmitterNode(); emitter.particleTexture = Self.glow
        emitter.particleColor = UIColor(hex: "ffc06a"); emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = .add; emitter.particleBirthRate = 55
        emitter.particleLifetime = 0.18; emitter.particleScale = 0.1
        emitter.particleScaleSpeed = -0.45; emitter.particleAlphaSpeed = -5
        emitter.targetNode = layer; node.addChild(emitter)
    }
}
