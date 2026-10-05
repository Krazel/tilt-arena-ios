import SpriteKit

/// Approved A, matching the audition's geometry, colors and 0.55-second decay.
/// Six reused shapes per chain segment; no per-frame node or emitter creation.
final class ClassicLightning: SKNode {
    private let glow = SKShapeNode(), core = SKShapeNode(), branches = SKShapeNode()
    private let impact = SKShapeNode(), sparks = SKShapeNode(), pulse = SKShapeNode()
    private let event: ClassicFrame.Event
    private let reduced: Bool
    private let color = UIColor(hex: "65bdff")
    init(event: ClassicFrame.Event, reduced: Bool) {
        self.event = event; self.reduced = reduced; super.init()
        name = "approved-lightning-A"
        position = CGPoint(x: event.x ?? 0, y: event.y ?? 0)
        for n in [glow, core, branches, impact, sparks, pulse] {
            n.fillColor = .clear; n.strokeColor = color; n.blendMode = .add; addChild(n)
        }
        glow.lineWidth = 8; glow.glowWidth = reduced ? 0 : 6.5
        core.lineWidth = 1.8; core.strokeColor = UIColor(hex: "e6f7ff")
        branches.lineWidth = 1.2; impact.lineWidth = 2; sparks.lineWidth = 1.5
        update(age: 0)
        run(.sequence([.customAction(withDuration: 0.55) { [weak self] _, t in self?.update(age: Double(t)) }, .removeFromParent()]))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    private func ring(_ node: SKShapeNode, radius: Double) {
        node.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
    }
    func update(age: Double) {
        let age = max(0, age), fade = max(0, 1 - age / 0.55)
        if event.kind == "electricPulse" {
            glow.isHidden = true; core.isHidden = true; branches.isHidden = true; sparks.isHidden = true
            ring(impact, radius: 18 + age * 90); impact.lineWidth = 5; impact.alpha = exp(-age * 24) * 0.6 * (fade > 0 ? 1 : 0)
            ring(pulse, radius: 14 + 130 * (1 - exp(-age * 9))); pulse.lineWidth = 1.5; pulse.alpha = fade * 0.22
            return
        }
        pulse.isHidden = true
        // Work in canvas coordinates then invert Y, preserving the approved paths.
        let dx = (event.toX ?? 0) - (event.x ?? 0), dy = (event.y ?? 0) - (event.toY ?? 0)
        let length = max(1, hypot(dx, dy)), segments = max(5, min(128, Int(ceil(length / 15))))
        let seed = floor(age * (reduced ? 0 : 28))
        var points = [CGPoint.zero]
        for i in 1..<segments {
            let n = sin((Double(i) + floor(event.x ?? 0)) * 127.1 + seed * 311.7) * 43758.5453
            let jitter = (n - floor(n) - 0.5) * 27, t = Double(i) / Double(segments)
            points.append(CGPoint(x: dx * t - dy / length * jitter, y: dy * t + dx / length * jitter))
        }
        points.append(CGPoint(x: dx, y: dy))
        func native(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x, y: -p.y) }
        let path = CGMutablePath(); path.move(to: .zero)
        for p in points.dropFirst() { path.addLine(to: native(p)) }
        glow.path = path; core.path = path; glow.alpha = fade * 0.22; core.alpha = fade
        let twigs = CGMutablePath()
        for i in stride(from: 2, to: points.count - 1, by: 3) {
            let p = points[i], sign = i % 2 == 1 ? 1.0 : -1.0
            twigs.move(to: native(p))
            twigs.addLine(to: native(CGPoint(x: p.x - dy / length * sign * 19 - dx / length * 8, y: p.y + dx / length * sign * 19 - dy / length * 8)))
            twigs.addLine(to: native(CGPoint(x: p.x - dy / length * sign * 29, y: p.y + dx / length * sign * 29)))
        }
        branches.path = twigs; branches.alpha = fade * 0.6
        impact.position = CGPoint(x: dx, y: -dy); ring(impact, radius: 4 + age * 44)
        impact.alpha = exp(-age * 14) * (fade > 0 ? 1 : 0)
        let rays = CGMutablePath()
        for i in 0..<(reduced ? 3 : 7) {
            let a = Double(i) * 2.39996, r = age * 65
            rays.move(to: CGPoint(x: cos(a) * r, y: -sin(a) * r))
            rays.addLine(to: CGPoint(x: cos(a) * (r + 7), y: -sin(a) * (r + 7)))
        }
        sparks.position = impact.position; sparks.path = rays; sparks.alpha = fade * 0.7
    }
}
