import SpriteKit

/// Filled teeth outside the green shield; driven by game time so pause is exact.
final class ClassicSpikes: SKNode {
    override init() {
        super.init()
        zPosition = 0.3
        for index in 0..<12 {
            let tooth = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 30, y: -5))
            path.addLine(to: CGPoint(x: 43, y: 0))
            path.addLine(to: CGPoint(x: 30, y: 5))
            path.closeSubpath()
            tooth.path = path
            tooth.fillColor = UIColor(hex: "ceeaff")
            tooth.strokeColor = UIColor(hex: "223968")
            tooth.lineWidth = 2
            tooth.zRotation = CGFloat(index) * .pi / 6
            addChild(tooth)
        }
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    func update(time: Double, until: Double, heading: Double, reduced: Bool) {
        let remaining = until - time
        isHidden = remaining <= 0
        // Counteract the parent arrow's heading for continuous world-space spin.
        zRotation = CGFloat((reduced ? 0 : time * 2.4) - heading)
        // Two gentle flashes per second during the last 1.25 s. Never disappear
        // completely while lethal; Reduce Motion retains a steady dim warning.
        if remaining > 0 && remaining <= 1.25 {
            alpha = reduced ? 0.65 : CGFloat(0.65 + 0.35 * cos(remaining * .pi * 4))
        } else { alpha = 1 }
    }
}
