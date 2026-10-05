import SpriteKit

/// Complete radial geometry: no atlas crop, masks or open filled arcs.
/// Persistent weapon art follows simulation time, including pause and skin changes.
final class ClassicAreaEffect: SKNode {
    private let ice: Bool, reduced: Bool, radius: CGFloat
    private let body = SKNode(), core = SKNode()
    private let front: SKShapeNode, echo: SKShapeNode
    private var details: [SKShapeNode] = []

    static func contour(radius: CGFloat, lobes: CGFloat = 0, roughness: CGFloat = 0) -> CGPath {
        let p = CGMutablePath()
        for i in 0..<120 {
            let a = CGFloat(i) / 120 * .pi * 2
            let r = radius * (1 + lobes * sin(a * 7 + 0.4) + roughness * sin(a * 19))
            let point = CGPoint(x: cos(a) * r, y: sin(a) * r)
            if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
        }
        p.closeSubpath(); return p
    }

    init(kind: String, radius: CGFloat, theme: VisualTheme, reduced: Bool) {
        ice = kind == "frost"; self.reduced = reduced; self.radius = radius
        let ink = theme == .inkTide, tint = UIColor(hex: kind == "frost" ? "79d9ed" : "ef8738")
        let light = ink ? InkArt.paper : UIColor.white
        front = SKShapeNode(path: Self.contour(radius: radius * 0.97, roughness: ink ? 0.009 : 0))
        echo = SKShapeNode(path: Self.contour(radius: radius * 0.78, roughness: ink ? 0.012 : 0))
        super.init(); addChild(body); addChild(front); addChild(echo); body.addChild(core)
        front.name = "complete-front"; echo.name = "complete-echo"
        front.strokeColor = ice ? tint : light; front.lineWidth = ice ? 2 : 3.5
        echo.strokeColor = tint; echo.lineWidth = 1.5
        front.fillColor = .clear; echo.fillColor = .clear
        let wash = SKShapeNode(path: Self.contour(radius: radius * 0.96, roughness: ink ? 0.008 : 0))
        wash.name = "complete-area"; wash.fillColor = tint.withAlphaComponent(ice ? 0.035 : 0.065)
        wash.strokeColor = tint.withAlphaComponent(0.24); wash.lineWidth = 1
        body.addChild(wash)
        if ice {
            // Six branching frost veins, surrounded by separate faceted crystals.
            for i in 0..<6 {
                let p = CGMutablePath(); p.move(to: CGPoint(x: radius * 0.08, y: 0))
                p.addLine(to: CGPoint(x: radius * 0.86, y: 0))
                for reach in [CGFloat(0.32), 0.55, 0.75] {
                    for side in [CGFloat(-1), 1] {
                        p.move(to: CGPoint(x: radius * reach, y: 0))
                        p.addLine(to: CGPoint(x: radius * (reach - 0.12), y: radius * 0.085 * side))
                    }
                }
                let vein = SKShapeNode(path: p); vein.strokeColor = tint
                vein.lineWidth = 1.6; vein.alpha = reduced ? 0.3 : 0.65
                vein.zRotation = CGFloat(i) * .pi / 3; body.addChild(vein)
            }
            for i in 0..<12 {
                let length = radius * (i % 2 == 0 ? 0.18 : 0.12), width = length * 0.22
                let p = CGMutablePath(); p.move(to: CGPoint(x: -length * 0.45, y: 0))
                p.addLine(to: CGPoint(x: 0, y: -width)); p.addLine(to: CGPoint(x: length, y: 0))
                p.addLine(to: CGPoint(x: length * 0.2, y: width)); p.closeSubpath()
                let crystal = SKShapeNode(path: p); crystal.name = "ice-crystal"
                crystal.fillColor = (i % 2 == 0 ? tint : light).withAlphaComponent(0.45)
                crystal.strokeColor = light; crystal.lineWidth = 1
                let a = CGFloat(i) * .pi / 6 + .pi / 12, distance = radius * (i % 2 == 0 ? 0.57 : 0.37)
                crystal.position = CGPoint(x: cos(a) * distance, y: sin(a) * distance)
                crystal.zRotation = a; body.addChild(crystal); details.append(crystal)
            }
            let center = SKShapeNode(path: ClassicArt.star(radius: radius * 0.14, inner: radius * 0.12, points: 6))
            center.fillColor = light.withAlphaComponent(0.2); center.strokeColor = tint; center.lineWidth = 1.5
            core.addChild(center)
        } else {
            // Closed, overlapping ink blooms replace the cropped explosion stamp.
            for i in 0..<3 {
                let bloom = SKShapeNode(path: Self.contour(radius: radius * (0.68 - CGFloat(i) * 0.17), lobes: 0.12, roughness: ink ? 0.025 : 0))
                bloom.name = "fire-bloom"; bloom.zRotation = CGFloat(i) * 0.55
                bloom.fillColor = [tint.withAlphaComponent(0.28), UIColor(hex: "ffc66c").withAlphaComponent(0.48), light.withAlphaComponent(0.8)][i]
                bloom.strokeColor = [tint, UIColor(hex: "ffd68a"), light][i]; bloom.lineWidth = 1.5
                core.addChild(bloom)
            }
            for i in 0..<(reduced ? 6 : 16) {
                let ember = SKShapeNode(ellipseOf: CGSize(width: radius * (i % 3 == 0 ? 0.095 : 0.055), height: radius * 0.025))
                ember.name = "ember"; ember.fillColor = i % 3 == 0 ? light : tint
                ember.strokeColor = .clear; body.addChild(ember); details.append(ember)
            }
        }
        update(remaining: 1, duration: 1)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(remaining: Double, duration: Double) {
        let age = max(0, duration - remaining), spread = CGFloat(1 - pow(1 - min(1, age / 0.24), 3))
        alpha = CGFloat(min(1, max(0, remaining) / 0.3))
        front.setScale(reduced ? 1 : 0.12 + spread * 0.88)
        echo.setScale(reduced ? 1 : 0.15 + spread * 0.85)
        front.alpha = CGFloat(max(0.12, 0.8 - age * 0.65)) * (reduced ? 0.4 : 1)
        echo.alpha = CGFloat(max(0.1, 0.5 - age * 0.45))
        if ice {
            body.setScale(reduced ? 1 : 0.08 + spread * 0.92)
            for (i, crystal) in details.enumerated() {
                crystal.alpha = reduced ? 0.4 : CGFloat(0.65 + 0.18 * sin(age * 4 + Double(i)))
            }
        } else {
            core.setScale(reduced ? 0.85 : 0.08 + spread * 0.92)
            core.alpha = CGFloat(max(0.14, 1 - age * 1.15)) * (reduced ? 0.4 : 1)
            for (i, ember) in details.enumerated() {
                let a = CGFloat(i) * 2.39996, distance = radius * (reduced ? 0.65 : 0.16 + spread * (0.46 + CGFloat(i % 3) * 0.1))
                ember.position = CGPoint(x: cos(a) * distance, y: sin(a) * distance)
                ember.zRotation = a
                ember.alpha = CGFloat(max(0.18, 0.85 - age * 0.5))
                ember.setScale(reduced ? 1 : CGFloat(max(0.4, 1 - age * 0.45)))
            }
        }
    }
}
