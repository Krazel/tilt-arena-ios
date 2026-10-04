import SpriteKit

/// The rendered segment is the exact one used by the shared simulation.
final class ClassicLaser: SKNode {
    private let outer = SKShapeNode(), core = SKShapeNode(), muzzle = SKShapeNode(circleOfRadius: 9)
    private let inkColor = UIColor(hex: "c97478"), classicColor = UIColor(hex: "ed8f91")
    private var lastLength: CGFloat?, lastTheme: VisualTheme?, lastReduced: Bool?
    override init() {
        super.init()
        for node in [outer, core, muzzle] { node.fillColor = .clear; addChild(node) }
        muzzle.lineWidth = 2; zPosition = 3.2
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(beam: ClassicFrame.Beam?, remaining: Double, time: Double, theme: VisualTheme, reduced: Bool) {
        guard let beam else { isHidden = true; return }; isHidden = false
        let dx = beam.toX - beam.x, dy = beam.toY - beam.y
        let length = CGFloat(hypot(dx, dy))
        position = CGPoint(x: beam.x, y: beam.y); zRotation = CGFloat(atan2(dy, dx))
        if lastLength != length {
            let path = CGMutablePath(); path.move(to: .zero)
            path.addLine(to: CGPoint(x: length, y: 0))
            outer.path = path; core.path = path; lastLength = length
        }
        outer.lineWidth = beam.width; core.lineWidth = 4
        if lastTheme != theme || lastReduced != reduced {
            outer.strokeColor = theme == .inkTide ? inkColor : classicColor
            core.strokeColor = theme == .inkTide ? InkArt.paper : .white
            outer.glowWidth = theme == .inkTide || reduced ? 0 : 3
            muzzle.strokeColor = outer.strokeColor
            lastTheme = theme; lastReduced = reduced
        }
        muzzle.setScale(reduced ? 1 : 1 + 0.12 * sin(time * 18))
        alpha = min(1, remaining / 0.12) * (reduced ? 1 : 0.94 + 0.06 * sin(time * 23))
    }
}
