import SpriteKit

/// Filled teeth outside the green shield; driven by game time so pause is exact.
final class ClassicSpikes: SKNode {
    private var teeth: [SKShapeNode] = []
    private let countdown = SKShapeNode()
    override init() {
        super.init()
        zPosition = 0.3
        for index in 0..<12 {
            let tooth = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 32, y: -6))
            path.addLine(to: CGPoint(x: 48, y: 0))
            path.addLine(to: CGPoint(x: 32, y: 6))
            path.closeSubpath()
            tooth.path = path
            tooth.fillColor = UIColor(hex: "ceeaff")
            tooth.strokeColor = UIColor(hex: "223968")
            tooth.lineWidth = 2
            tooth.zRotation = CGFloat(index) * .pi / 6
            addChild(tooth); teeth.append(tooth)
        }
        countdown.name = "expiry-ring"; countdown.strokeColor = UIColor(hex: "fff3a6")
        countdown.lineWidth = 3; countdown.lineCap = .round
        countdown.glowWidth = 1; addChild(countdown)
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    func update(time: Double, until: Double, heading: Double, reduced: Bool) {
        let remaining = until - time
        isHidden = remaining <= 0
        // Counteract the parent arrow's heading for continuous world-space spin.
        let spin = reduced ? 0 : time * 4.2
        zRotation = CGFloat(spin - heading)
        let warning = remaining > 0 && remaining <= 1.5
        // Whole power stays readable: only the teeth pulse. Color and a shrinking
        // fixed-world countdown arc warn even with Reduce Motion enabled.
        alpha = 1; countdown.isHidden = !warning
        for tooth in teeth {
            tooth.fillColor = UIColor(hex: warning ? "ffbf55" : "ceeaff")
            tooth.strokeColor = UIColor(hex: warning ? "fff4cd" : "223968")
            tooth.alpha = warning && !reduced ? CGFloat(0.7 + 0.3 * cos(remaining * .pi * 4)) : 1
        }
        if warning {
            let path = CGMutablePath()
            path.addArc(center: .zero, radius: 54, startAngle: .pi / 2,
                        endAngle: .pi / 2 + CGFloat(remaining / 1.5) * .pi * 2, clockwise: false)
            countdown.path = path; countdown.zRotation = CGFloat(-spin)
            countdown.glowWidth = reduced ? 0 : 1
        }
    }
}
