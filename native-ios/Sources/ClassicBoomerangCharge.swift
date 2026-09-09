import SpriteKit

/// Golden blades gather at the tip; progress follows simulation time and pause.
final class ClassicBoomerangCharge: SKNode {
    private let blades = ClassicArt.node(style: "boomerangShot")
    private let ring = SKShapeNode()
    override init() {
        super.init()
        position = CGPoint(x: 38, y: 0)
        blades.name = "charging-blades"; addChild(blades)
        ring.name = "charge-ring"; ring.strokeColor = UIColor(hex: "ffe4a1")
        ring.lineWidth = 2.5; ring.lineCap = .round; addChild(ring)
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(progress: Double, active: Bool, reduced: Bool) {
        isHidden = !active
        guard active else { return }
        let p = CGFloat(max(0, min(1, progress)))
        blades.setScale(0.32 + p * 0.28)
        blades.alpha = 0.5 + p * 0.5
        blades.zRotation = reduced ? 0 : p * .pi * 2
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: 21, startAngle: -.pi / 2,
                    endAngle: -.pi / 2 + 2 * .pi * max(0.002, p), clockwise: false)
        ring.path = path; ring.glowWidth = reduced ? 0 : 1.5
    }
}
