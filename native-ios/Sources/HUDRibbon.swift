import SpriteKit

/// Text is measured separately; only the middle of the artwork stretches.
final class HUDRibbon: SKNode {
    private let left: SKSpriteNode
    private let center: SKSpriteNode
    private let right: SKSpriteNode
    private(set) var backingFrame = CGRect.zero
    static let padding: CGFloat = 32

    override init() {
        let texture = SKTexture(imageNamed: "ink-hud-ribbon.png")
        left = SKSpriteNode(texture: SKTexture(rect: CGRect(x: 0, y: 0, width: 0.12, height: 1), in: texture))
        center = SKSpriteNode(texture: SKTexture(rect: CGRect(x: 0.12, y: 0, width: 0.76, height: 1), in: texture))
        right = SKSpriteNode(texture: SKTexture(rect: CGRect(x: 0.88, y: 0, width: 0.12, height: 1), in: texture))
        super.init()
        for piece in [left, center, right] { piece.anchorPoint = CGPoint(x: 0, y: 0.5); addChild(piece) }
        zPosition = -1
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    func fit(textFrame: CGRect, minimumContentWidth: CGFloat = 0, height: CGFloat = 36) {
        let contentWidth = max(textFrame.width, minimumContentWidth)
        let next = CGRect(x: textFrame.minX - Self.padding, y: textFrame.midY - height / 2,
                          width: contentWidth + 2 * Self.padding, height: height)
        guard next != backingFrame else { return }
        backingFrame = next; position = CGPoint(x: next.minX, y: next.midY)
        left.position = .zero; left.size = CGSize(width: Self.padding, height: height)
        center.position = CGPoint(x: Self.padding, y: 0); center.size = CGSize(width: contentWidth, height: height)
        right.position = CGPoint(x: Self.padding + contentWidth, y: 0); right.size = left.size
    }
}
