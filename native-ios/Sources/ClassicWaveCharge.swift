import SpriteKit

/// Energy gathers at the arrow tip using game time, including while moving.
final class ClassicWaveCharge: SKNode {
    private let core = SKShapeNode(circleOfRadius: 7)
    private let ring = SKShapeNode()
    private var sparks: [SKShapeNode] = []

    override init() {
        super.init()
        position = CGPoint(x: 28, y: 0)
        core.fillColor = UIColor(hex: "f4ddff"); core.strokeColor = UIColor(hex: "b868ec")
        core.lineWidth = 2; addChild(core)
        ring.strokeColor = UIColor(hex: "c48aff"); ring.lineWidth = 2.5
        ring.lineCap = .round; addChild(ring)
        for _ in 0..<6 {
            let spark = SKShapeNode(path: ClassicArt.star(radius: 3, inner: 1, points: 4))
            spark.fillColor = UIColor(hex: "ead0ff"); spark.strokeColor = .clear
            addChild(spark); sparks.append(spark)
        }
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(progress: Double, active: Bool, reduced: Bool) {
        isHidden = !active
        guard active else { return }
        let p = CGFloat(max(0, min(1, progress)))
        core.setScale(0.3 + p * 0.9); core.alpha = 0.45 + p * 0.55
        core.glowWidth = reduced ? 0 : 2 + p * 4
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: 19 - p * 5, startAngle: -.pi / 2,
                    endAngle: -.pi / 2 + 2 * .pi * max(0.002, p), clockwise: false)
        ring.path = path; ring.glowWidth = reduced ? 0 : 1.5
        for (i, spark) in sparks.enumerated() {
            spark.isHidden = reduced
            let phase = (p * 1.8 + CGFloat(i) / 6).truncatingRemainder(dividingBy: 1)
            let angle = CGFloat(i) * .pi / 3 + p * 0.7
            let radius = 28 - phase * 20
            spark.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            spark.alpha = sin(phase * .pi)
        }
    }
}
