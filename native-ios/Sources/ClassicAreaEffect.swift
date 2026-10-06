import SpriteKit

/// Approved ice A / blast A. All nodes and paths are prepared once per field.
/// Movement, cooling and expiry use game time; no actions run while paused.
final class ClassicAreaEffect: SKNode {
    private let ice: Bool, reduced: Bool
    private let art = SKNode()
    private struct Part { let node: SKNode, kind: Int, i: Int, angle: Double, a: Double, b: Double, c: Double }
    private var parts: [Part] = []
    private static func random(_ i: Int, _ seed: Int = 1) -> Double {
        let n = sin(Double(i) * 127.1 + Double(seed) * 311.7) * 43758.5453
        return n - floor(n)
    }
    private static func ease(_ x: Double) -> Double { 1 - pow(1 - max(0, min(1, x)), 3) }
    private static func texture(smoke: Bool) -> SKTexture {
        let format = UIGraphicsImageRendererFormat(); format.scale = 1
        return SKTexture(image: UIGraphicsImageRenderer(size: CGSize(width: 64, height: 64), format: format).image { ctx in
            let colors = smoke ? [UIColor(hex: "aa5a22").cgColor, UIColor(hex: "373335").cgColor, UIColor.clear.cgColor] : [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, smoke ? 0.5 : 0.24, 1])!
            ctx.cgContext.drawRadialGradient(gradient, startCenter: CGPoint(x: smoke ? 26 : 32, y: smoke ? 39 : 32), startRadius: 0, endCenter: CGPoint(x: 32, y: 32), endRadius: 32, options: [])
        })
    }
    private static let glow = texture(smoke: false), smoke = texture(smoke: true)
    static func preloadTextures() { SKTexture.preload([glow, smoke], withCompletionHandler: {}) }
    static func contour(radius: CGFloat, lobes: CGFloat = 0, roughness: CGFloat = 0) -> CGPath {
        let p = CGMutablePath()
        for i in 0..<120 {
            let a = CGFloat(i) / 120 * .pi * 2
            let r = radius * (1 + lobes * sin(a * 9 + 2) + roughness * sin(a * 17 - 2))
            let v = CGPoint(x: cos(a) * r, y: sin(a) * r)
            if i == 0 { p.move(to: v) } else { p.addLine(to: v) }
        }
        p.closeSubpath(); return p
    }
    init(kind: String, radius: CGFloat, theme: VisualTheme, reduced: Bool) {
        ice = kind == "frost"; self.reduced = reduced
        super.init()
        let wash = SKShapeNode(path: Self.contour(radius: radius * 0.96))
        wash.name = "complete-area"; wash.fillColor = UIColor(hex: ice ? "79d9ed" : "ef8738").withAlphaComponent(0.018)
        wash.strokeColor = .clear; addChild(wash)
        addChild(art); art.setScale(radius / (ice ? 145 : 165))
        if ice {
            for i in 0..<11 {
                let a = Double(i) / 11 * .pi * 2, len = 129 * (0.62 + Self.random(i) * 0.33)
                let p = CGMutablePath(); p.move(to: .zero)
                var points: [CGPoint] = [.zero]
                for j in 1...6 {
                    let r = len * Double(j) / 6, theta = a + (Self.random(j, i + 2) - 0.5) * 0.16
                    let v = CGPoint(x: cos(theta) * r, y: sin(theta) * r); p.addLine(to: v); points.append(v)
                }
                for j in 2..<5 {
                    let b = a + (j % 2 == 1 ? 1.0 : -1.0) * 0.67
                    p.move(to: points[j]); p.addLine(to: CGPoint(x: points[j].x + cos(b) * len * 0.18, y: points[j].y + sin(b) * len * 0.18))
                }
                add(shape(p, "86e9f0", 1), 0, i)
            }
            add(ring(129, "bdefff", 3.5), 1, 0)
            for i in 0..<(reduced ? 24 : 82) {
                let n = shard(2 + Self.random(i) * 6, ice: true); n.name = "ice-fragment"
                add(n, 2, i, angle: Self.random(i, 2) * .pi * 2, a: 32 + Self.random(i, 7) * 110, b: 0.35 + Self.random(i, 6) * 1.7, c: (Self.random(i, 4) - 0.5) * 9)
            }
            for i in 0..<(reduced ? 4 : 18) { add(glowNode("78bbc4", additive: false), 3, i, angle: Self.random(i, 11) * .pi * 2, a: Self.random(i, 12) * 129) }
            add(glowNode("89e9fb"), 4, 0)
        } else {
            for i in 0..<(reduced ? 8 : 26) { add(SKSpriteNode(texture: Self.smoke), 5, i, angle: Double(i) * 2.39996, a: Self.random(i, 4) * 0.13, b: 22 + Self.random(i, 2) * 80) }
            add(glowNode("fa6b18"), 6, 0); add(glowNode("fff1b9"), 6, 1)
            for i in 0..<(reduced ? 5 : 13) { for k in 0..<(i % 3 == 0 ? 3 : 2) {
                add(glowNode(["ff5412", "ffce65", "fff6cd"][k]), 7, i, angle: Double(i) * 2.39996, a: Self.random(i, 26) * 0.025, b: 15 + Self.random(i, 27) * 52, c: Double(k))
            } }
            add(ring(150, "ffd59c", 4), 8, 0); add(ring(130, "ffd59c", 1), 8, 1)
            for i in 0..<(reduced ? 8 : 34) {
                let p = CGMutablePath(); p.move(to: .zero)
                p.addCurve(to: CGPoint(x: -1, y: 0), control1: CGPoint(x: -0.25, y: -1), control2: CGPoint(x: -0.65, y: 0.7))
                p.addCurve(to: .zero, control1: CGPoint(x: -0.5, y: -0.6), control2: CGPoint(x: -0.25, y: 0.65)); p.closeSubpath()
                let n = SKShapeNode(path: p); n.fillColor = UIColor(hex: "ffac40"); n.strokeColor = .clear
                add(n, 9, i, angle: Double(i) * 2.39996, a: Self.random(i) * 0.045, b: 55 + Self.random(i, 7) * 55, c: 22 + Self.random(i) * 32)
            }
            for i in 0..<(reduced ? 24 : 92) {
                let n = SKSpriteNode(color: UIColor(hex: i % 4 == 0 ? "ffeabd" : "ff762c"), size: CGSize(width: 1, height: 1))
                n.anchorPoint = CGPoint(x: 1, y: 0.5); n.blendMode = .add; n.name = "ember"
                add(n, 10, i, angle: Self.random(i, 9) * .pi * 2, a: Self.random(i, 8) * 0.07, b: 45 + Self.random(i, 3) * 110, c: 0.35 + Self.random(i, 5) * 1.75)
            }
            for i in 0..<(reduced ? 5 : 20) { add(shard(1 + Self.random(i) * 2.5, ice: false), 11, i, angle: Self.random(i, 15) * .pi * 2, a: 25 + Self.random(i, 11) * 112) }
        }
        update(remaining: 1, duration: 1)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    private func shape(_ path: CGPath, _ color: String, _ width: CGFloat) -> SKShapeNode { let n = SKShapeNode(path: path); n.fillColor = .clear; n.strokeColor = UIColor(hex: color); n.lineWidth = width; return n }
    private func ring(_ radius: CGFloat, _ color: String, _ width: CGFloat) -> SKShapeNode { shape(Self.contour(radius: radius, lobes: 0.022, roughness: 0.014), color, width) }
    private func glowNode(_ color: String, additive: Bool = true) -> SKSpriteNode { let n = SKSpriteNode(texture: Self.glow); n.color = UIColor(hex: color); n.colorBlendFactor = 1; n.blendMode = additive ? .add : .alpha; return n }
    private func shard(_ size: Double, ice: Bool) -> SKShapeNode {
        let p = CGMutablePath(); p.move(to: CGPoint(x: size, y: 0)); p.addLine(to: CGPoint(x: -size * 0.55, y: size * 0.26)); p.addLine(to: CGPoint(x: -size * 0.28, y: -size * 0.3)); p.closeSubpath()
        let n = SKShapeNode(path: p); n.fillColor = UIColor(hex: ice ? "b9f3f5" : "ffb953"); n.strokeColor = UIColor(hex: ice ? "fff5de" : "fff1b0"); n.lineWidth = 0.45; return n
    }
    private func add(_ node: SKNode, _ kind: Int, _ i: Int, angle: Double = 0, a: Double = 0, b: Double = 0, c: Double = 0) { art.addChild(node); parts.append(Part(node: node, kind: kind, i: i, angle: angle, a: a, b: b, c: c)) }
    func update(remaining: Double, duration: Double) {
        let age = max(0, duration - remaining), motion = reduced ? 0.35 : 1.0
        alpha = CGFloat(min(1, max(0, remaining) / 0.25))
        for p in parts {
            let n = p.node; var opacity = 1.0
            func place(_ r: Double, _ drift: Double = 0) { n.position = CGPoint(x: cos(p.angle) * r, y: sin(p.angle) * r - drift) }
            func diameter(_ r: Double) { (n as? SKSpriteNode)?.size = CGSize(width: r * 2, height: r * 2) }
            switch p.kind {
            case 0: n.setScale(CGFloat(Self.ease(age / 0.2))); opacity = min(1, max(0, (2 - age) / 1.8)) * 0.5
            case 1: n.setScale(CGFloat(Self.ease(age / 0.18))); opacity = exp(-age * 6)
            case 2: place(p.a * (1 - exp(-age * 4)), age * age * 8 * motion); n.zRotation = CGFloat(p.angle + age * p.c * motion); opacity = min(1, max(0, (p.b - age) / 0.3))
            case 3:
                let q = max(0, age - 0.15); place(p.a); n.position.x += CGFloat(q * 8 * motion); n.position.y += CGFloat(q * 8 * motion); diameter(15 + q * 8); opacity = sin(min(1, q / 2.4) * .pi) * 0.25
            case 4: diameter(42 + age * 130); opacity = exp(-age * 21) * 0.8
            case 5:
                let q = max(0, age - p.a); place(p.b * Self.ease(q / 1.1), -q * 14 * motion); diameter(16 + q * 23); opacity = min(1, q / 0.16) * min(1, max(0, (2.2 - q) / 0.8)) * 0.58
            case 6: diameter(p.i == 0 ? 25 + 115 * Self.ease(age / 0.19) : 12 + 45 * Self.ease(age / 0.07)); opacity = exp(-age * (p.i == 0 ? 5 : 24)) * (p.i == 0 ? 0.85 : 1)
            case 7:
                let q = max(0, age - p.a), r = p.b * Self.ease(q / 0.3), a = p.angle + q * 0.4 * motion
                n.position = CGPoint(x: cos(a) * r, y: sin(a) * r)
                let size = (19 + Self.random(p.i, 28) * 20) * (1 + q * 0.7)
                diameter(size * (p.c == 0 ? 1.55 : p.c == 1 ? 0.8 : 0.35)); opacity = min(1, q / 0.025) * exp(-q * 6) * (p.c == 0 ? 0.72 : p.c == 1 ? 0.75 : 0.6)
            case 8: n.setScale(CGFloat(Self.ease(age / (p.i == 0 ? 0.27 : 0.36)))); opacity = exp(-age * (p.i == 0 ? 10 : 8)) * (p.i == 0 ? 0.85 : 0.22)
            case 9:
                let q = max(0, age - p.a); place(p.b * Self.ease(q / 0.26)); n.zRotation = CGFloat(p.angle); n.xScale = CGFloat(p.c * exp(-q * 2.8)); n.yScale = CGFloat(9 + Self.random(p.i) * 15); opacity = exp(-q * 5)
            case 10:
                let q = max(0, age - p.a); place(p.b * (1 - exp(-q * 3)), q * q * 8 * motion); n.zRotation = CGFloat(p.angle)
                (n as? SKSpriteNode)?.size = CGSize(width: max(1, 12 * exp(-q * 2)), height: p.i % 7 == 0 ? 2.2 : 1)
                opacity = age < p.a ? 0 : min(1, max(0, (p.c - q) / 0.4))
            default: place(p.a * Self.ease(age / 0.3), age * age * 13 * motion); n.zRotation = CGFloat(p.angle + age * 4 * motion); opacity = min(1, max(0, (1.7 - age) / 0.6))
            }
            n.alpha = CGFloat(max(0, min(1, opacity)) * (reduced ? 0.55 : 1)); n.isHidden = n.alpha < 0.005
        }
    }
}
