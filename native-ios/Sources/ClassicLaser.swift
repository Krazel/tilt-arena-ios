import SpriteKit

/// The rendered segment is the exact one used by the shared simulation.
final class ClassicLaser: SKNode {
    private let outer = SKShapeNode(), core = SKShapeNode(), muzzle = SKShapeNode(circleOfRadius: 9)
    private let inkColor = UIColor(hex: "c97478"), classicColor = UIColor(hex: "ed8f91")
    private var lastLength: CGFloat?, lastTheme: VisualTheme?, lastReduced: Bool?
    private let trial = SKNode()
    private let bands = (0..<3).map { _ in SKShapeNode() }
    private let ends = (0..<2).map { _ in SKShapeNode(circleOfRadius: 9) }
    private let sparks = (0..<14).map { _ in SKShapeNode() }
    override init() {
        super.init()
        for node in [outer, core, muzzle] { node.fillColor = .clear; addChild(node) }
        muzzle.lineWidth = 2; zPosition = 3.2
        addChild(trial)
        for n in bands + ends + sparks { n.fillColor = .clear; trial.addChild(n) }
        for n in sparks {
            let p = CGMutablePath(); p.move(to: .zero); p.addLine(to: CGPoint(x: 6, y: 0)); n.path = p
            n.strokeColor = UIColor(hex: "d7afff"); n.lineWidth = 2
        }
        for n in ends { n.fillColor = UIColor(hex: "e1b7ff"); n.strokeColor = .clear }

    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(beam: ClassicFrame.Beam?, remaining: Double, time: Double, theme: VisualTheme, reduced: Bool, style: LaserStyle = .current) {
        guard let beam else { isHidden = true; return }; isHidden = false
        let dx = beam.toX - beam.x, dy = beam.toY - beam.y
        let length = CGFloat(hypot(dx, dy))
        position = CGPoint(x: beam.x, y: beam.y); zRotation = CGFloat(atan2(dy, dx))
        trial.isHidden = style == .current
        for n in [outer, core, muzzle] { n.isHidden = style != .current }
        if style != .current {
            updateTrial(length: length, time: time, remaining: remaining, style: style, reduced: reduced)
            return
        }
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
    private func updateTrial(length: CGFloat, time: Double, remaining: Double, style: LaserStyle, reduced: Bool) {
        alpha = min(1, max(0, remaining) / 0.12) * (reduced ? 0.65 : 1)
        for (j, node) in bands.enumerated() {
            let path = CGMutablePath()
            if style == .plasma {
                path.move(to: .zero); path.addLine(to: CGPoint(x: length, y: 0))
                node.strokeColor = UIColor(hex: ["993bf5", "d88fff", "fff4ff"][j])
                node.lineWidth = [28.0, 12, 4][j]; node.alpha = j == 0 ? 0.35 : 1
            } else {
                for i in 0..<48 {
                    let y = reduced ? Double(j * 6 - 6) : sin(Double(i) * 0.8 + time * 16 + Double(j)) * 4 + Double(j * 6 - 6)
                    let point = CGPoint(x: length * CGFloat(i) / 47, y: -y)
                    if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
                }
                node.strokeColor = UIColor(hex: j == 1 ? "fff3e5" : "a987c9")
                node.lineWidth = j == 1 ? 4 : 8; node.alpha = j == 1 ? 1 : 0.55
            }
            node.path = path
        }
        ends[0].position = .zero; ends[1].position = CGPoint(x: length, y: 0)
        for (i, end) in ends.enumerated() {
            end.glowWidth = reduced ? 0 : 14; end.alpha = i == 0 ? 0.5 : 0.65
            end.setScale(reduced ? 1 : 1 + (i == 0 ? 0 : 0.18 * sin(time * 32)))
        }
        for (i, spark) in sparks.enumerated() {
            let q = (time * 2.2 + Double(i) * 0.61803398875).truncatingRemainder(dividingBy: 1)
            let angle = Double(i) * 2.39996323
            spark.position = CGPoint(x: length + cos(angle) * q * 50, y: sin(angle) * q * 50)
            spark.zRotation = CGFloat(angle); spark.alpha = reduced ? 0 : 1 - q
        }
    }

}
