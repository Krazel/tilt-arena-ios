import SpriteKit

/// The rendered segment is the exact one used by the shared simulation.
final class ClassicLaser: SKNode {
    private let outer = SKShapeNode(), core = SKShapeNode(), muzzle = SKShapeNode(circleOfRadius: 9)
    override init() {
        super.init()
        for node in [outer, core, muzzle] { node.fillColor = .clear; addChild(node) }
        muzzle.lineWidth = 2; zPosition = 3.2
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(beam: ClassicFrame.Beam?, remaining: Double, time: Double, theme: VisualTheme, reduced: Bool) {
        guard let beam else { isHidden = true; return }; isHidden = false
        let path = CGMutablePath(); path.move(to: CGPoint(x: beam.x, y: beam.y))
        path.addLine(to: CGPoint(x: beam.toX, y: beam.toY))
        outer.path = path; core.path = path
        outer.lineWidth = beam.width; core.lineWidth = 4
        outer.strokeColor = UIColor(hex: theme == .inkTide ? "c97478" : "ed8f91")
        core.strokeColor = theme == .inkTide ? InkArt.paper : .white
        outer.glowWidth = theme == .inkTide || reduced ? 0 : 3
        muzzle.strokeColor = outer.strokeColor; muzzle.position = CGPoint(x: beam.x, y: beam.y)
        muzzle.setScale(reduced ? 1 : 1 + 0.12 * sin(time * 18))
        alpha = min(1, remaining / 0.12) * (reduced ? 1 : 0.94 + 0.06 * sin(time * 23))
    }
}
