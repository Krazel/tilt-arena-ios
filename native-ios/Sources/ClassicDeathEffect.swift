import SpriteKit

/// Approved A: paper/red fragments and a short warm flash, independent of theme.
final class ClassicDeathEffect: SKNode {
    private var shards: [SKShapeNode] = []
    private let flash = SKShapeNode(circleOfRadius: 16)
    private let reduced: Bool
    private static func noise(_ i: Int, _ seed: Int) -> Double {
        let x = sin(Double(i) * 127.1 + Double(seed) * 311.7) * 43758.5453
        return x - floor(x)
    }
    init(reduced: Bool) {
        self.reduced = reduced; super.init(); name = "approved-death-A"
        flash.fillColor = UIColor(hex: "ffe4af"); flash.strokeColor = .clear; flash.glowWidth = reduced ? 0 : 14; addChild(flash)
        for i in 0..<(reduced ? 6 : 13) {
            let path = CGMutablePath(); path.move(to: .zero); path.addLine(to: CGPoint(x: 14, y: 0))
            let shard = SKShapeNode(path: path); shard.lineWidth = 6
            shard.strokeColor = UIColor(hex: i % 5 == 0 ? "df5841" : "efe1c1")
            addChild(shard); shards.append(shard)
        }
        update(age: 0)
        run(.sequence([.customAction(withDuration: 2.4) { [weak self] _, time in self?.update(age: Double(time)) }, .removeFromParent()]))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }
    func update(age: Double) {
        let q = max(0, age), spread = 1 - pow(1 - min(1, q / 0.8), 3)
        flash.alpha = exp(-q * 12) * (reduced ? 0.2 : 0.65)
        for (i, shard) in shards.enumerated() {
            let a = Self.noise(i, 7) * .pi * 2, r = (15 + Self.noise(i, 3) * 65) * spread * (reduced ? 0.7 : 2)
            shard.position = CGPoint(x: cos(a) * r, y: sin(a) * r - q * q * (reduced ? 2 : 12))
            shard.zRotation = CGFloat(a + (reduced ? 0 : q * 2))
            shard.alpha = CGFloat(max(0, min(1, (1.8 + Self.noise(i, 1) * 0.6 - q) / 0.8)))
        }
    }
}
