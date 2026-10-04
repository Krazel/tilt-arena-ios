import SpriteKit

/// Filled teeth outside the green shield; driven by game time so pause is exact.
final class ClassicSpikes: SKNode {
    private var teeth: [SKShapeNode] = []
    private let countdown = SKShapeNode()
    private let theme: VisualTheme
    private let activeFill: UIColor, activeStroke: UIColor, warningFill: UIColor, warningStroke: UIColor
    private var lastWarning: Bool?
    init(theme: VisualTheme = .classic) {
        self.theme = theme
        activeFill = theme == .inkTide ? InkArt.paper : UIColor(hex: "ceeaff")
        activeStroke = theme == .inkTide ? InkArt.gold : UIColor(hex: "223968")
        warningFill = theme == .inkTide ? InkArt.gold : UIColor(hex: "ffbf55")
        warningStroke = theme == .inkTide ? InkArt.paper : UIColor(hex: "fff4cd")
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
            tooth.fillColor = theme == .inkTide ? InkArt.paper : UIColor(hex: "ceeaff")
            tooth.strokeColor = theme == .inkTide ? InkArt.gold : UIColor(hex: "223968")
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
        guard remaining > 0 else { isHidden = true; return }
        isHidden = false
        // Counteract the parent arrow's heading for continuous world-space spin.
        let spin = reduced ? 0 : time * 4.2
        zRotation = CGFloat(spin - heading)
        let warning = remaining > 0 && remaining <= 1.5
        // Whole power stays readable: only the teeth pulse. Color and a shrinking
        // fixed-world countdown arc warn even with Reduce Motion enabled.
        alpha = 1; countdown.isHidden = !warning
        for tooth in teeth {
            if lastWarning != warning {
                tooth.fillColor = warning ? warningFill : activeFill
                tooth.strokeColor = warning ? warningStroke : activeStroke
            }
            tooth.alpha = warning && !reduced ? CGFloat(0.7 + 0.3 * cos(remaining * .pi * 4)) : 1
        }
        lastWarning = warning
        if warning {
            let path = CGMutablePath()
            path.addArc(center: .zero, radius: 54, startAngle: .pi / 2,
                        endAngle: .pi / 2 + CGFloat(remaining / 1.5) * .pi * 2, clockwise: false)
            countdown.path = theme == .inkTide ? InkArt.ringPath(radius: 54, fraction: CGFloat(remaining / 1.5), phase: .pi / 2) : path
            countdown.zRotation = CGFloat(-spin)
            countdown.glowWidth = reduced || theme == .inkTide ? 0 : 1
        }
    }
}
