import SpriteKit

/// Driven by simulation progress, so pausing freezes charge and aim together.
final class ClassicFireCharge: SKNode {
    private let progressRing = SKShapeNode()
    private let halo = SKShapeNode(circleOfRadius: 31)
    private var embers: [SKShapeNode] = []

    override init() {
        super.init()
        halo.fillColor = UIColor(hex: "ff872b").withAlphaComponent(0.16)
        halo.strokeColor = UIColor(hex: "ffb644").withAlphaComponent(0.45)
        halo.lineWidth = 1.5; addChild(halo)
        progressRing.strokeColor = UIColor(hex: "fff0ae"); progressRing.lineWidth = 3.5
        progressRing.lineCap = .round; addChild(progressRing)
        let path = CGMutablePath()
        for x in [CGFloat(42), CGFloat(55)] {
            path.move(to: CGPoint(x: x, y: -6)); path.addLine(to: CGPoint(x: x + 6, y: 0))
            path.addLine(to: CGPoint(x: x, y: 6))
        }
        let aim = SKShapeNode(path: path); aim.strokeColor = UIColor(hex: "ffe6a1")
        aim.lineWidth = 2; addChild(aim)
        for _ in 0..<8 {
            let ember = SKShapeNode(path: ClassicArt.star(radius: 4, inner: 1.7, points: 4))
            ember.fillColor = UIColor(hex: "ffd266"); ember.strokeColor = .clear
            addChild(ember); embers.append(ember)
        }
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(progress: Double, active: Bool, reduced: Bool) {
        isHidden = !active
        guard active else { return }
        let p = CGFloat(max(0, min(1, progress)))
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: 31, startAngle: -.pi / 2,
                    endAngle: -.pi / 2 + 2 * .pi * max(0.002, p), clockwise: false)
        progressRing.path = path; progressRing.glowWidth = reduced ? 0 : 2
        halo.alpha = 0.45 + p * 0.55
        for (i, ember) in embers.enumerated() {
            ember.isHidden = reduced
            let phase = (p * 1.7 + CGFloat(i) / 8).truncatingRemainder(dividingBy: 1)
            let angle = CGFloat(i) * .pi / 4 + p * 0.9
            let radius = 52 - 31 * phase
            ember.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            ember.alpha = sin(phase * .pi); ember.setScale(0.6 + p * 0.6)
        }
    }
}
