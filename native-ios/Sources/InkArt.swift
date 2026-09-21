import SpriteKit
import UIKit

/// Approved Ink Tide print artwork. Cells share a single transparent texture;
/// sprites and glyphs remain independent of the simulation's collision shapes.
enum InkArt {
    static let paper = UIColor(hex: "eee4c9")
    static let gold = UIColor(hex: "c79a49")
    static let teal = UIColor(hex: "55969a")
    static let blue = UIColor(hex: "4a94cf")
    static let red = UIColor(hex: "ed4128")
    static let atlas = SKTexture(imageNamed: "ink-tide-sprites")
    static let arena = SKTexture(imageNamed: "ink-tide-arena")
    static let cells: [SKTexture] = (0..<8).map { index in
        SKTexture(rect: CGRect(x: CGFloat(index % 4) / 4, y: index < 4 ? 0.5 : 0,
                               width: 0.25, height: 0.5), in: atlas)
    }
    static func sprite(_ index: Int, size: CGFloat) -> SKSpriteNode {
        let node = SKSpriteNode(texture: cells[index]); node.size = CGSize(width: size, height: size)
        node.blendMode = .alpha; return node
    }
    static func color(for power: String?) -> UIColor {
        switch power {
        case "wave", "frost": return blue
        case "burn", "nuke", "boomerang", "blast", "burnLaunch", "boomerangLaunch", "boomerangBounce", "boomerangCatch": return gold
        case "vortex", "bubble": return teal
        case "kill": return red
        default: return paper
        }
    }
    static func node(style: String) -> SKNode {
        switch style {
        case "arrow", "missileShot":
            let root = SKNode(), dart = sprite(0, size: style == "arrow" ? 62 : 29)
            // The authored paper tip points upper-left; align it to engine +X.
            dart.zRotation = -2.46; root.addChild(dart); return root
        case "dot":
            let dot = sprite(1, size: 64)
            // Collision origin is the round red head, never the decorative tail.
            dot.anchorPoint = CGPoint(x: 0.75, y: 0.55); return dot
        case "waveShot": return sprite(3, size: 135)
        case "fire": return sprite(4, size: 80)
        case "vortexField": return sprite(5, size: 450)
        case "boomerangShot": return sprite(7, size: 78)
        default:
            let root = SKNode(); root.addChild(sprite(2, size: 60))
            // Keep the learned power symbols, with paper ink instead of glass.
            let original = ClassicArt.node(style: style)
            for child in Array(original.children.dropFirst(2)) {
                child.removeFromParent(); paperGlyph(child); root.addChild(child)
            }
            if style == "wave" {
                for child in Array(root.children.dropFirst()) { child.removeFromParent() }
                let p = CGMutablePath()
                for i in 0...60 {
                    let a = CGFloat(i) * 0.13, r = 2 + CGFloat(i) * 0.15
                    let point = CGPoint(x: cos(a) * r, y: sin(a) * r)
                    if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
                }
                let swirl = SKShapeNode(path: p); swirl.strokeColor = paper; swirl.lineWidth = 2.5
                root.addChild(swirl)
            } else if style == "vortex" {
                for child in Array(root.children.dropFirst()) { child.removeFromParent() }
                for i in 0..<3 {
                    let p = CGMutablePath(); p.move(to: CGPoint(x: 0, y: 2))
                    p.addCurve(to: CGPoint(x: 0, y: 11), control1: CGPoint(x: 14, y: -2), control2: CGPoint(x: 13, y: 12))
                    p.addQuadCurve(to: CGPoint(x: 0, y: 2), control: CGPoint(x: 7, y: 7)); p.closeSubpath()
                    let arm = SKShapeNode(path: p); arm.fillColor = paper; arm.strokeColor = .clear
                    arm.zRotation = CGFloat(i) * .pi * 2 / 3; root.addChild(arm)
                }
            }
            return root
        }
    }
    private static func paperGlyph(_ node: SKNode) {
        if let shape = node as? SKShapeNode {
            shape.strokeColor = paper; shape.glowWidth = 0
            if shape.fillColor.cgColor.alpha > 0 { shape.fillColor = paper }
        }
        node.children.forEach(paperGlyph)
    }
    /// Deterministic irregular stroke: no random work and no glow per frame.
    static func ringPath(radius: CGFloat, fraction: CGFloat = 1, phase: CGFloat = 0) -> CGPath {
        let p = CGMutablePath(), steps = max(2, Int(100 * max(0.002, fraction)))
        for i in 0...steps {
            let a = phase + CGFloat(i) / CGFloat(steps) * .pi * 2 * max(0.002, fraction)
            let r = radius * (1 + 0.018 * sin(a * 13) + 0.012 * cos(a * 23))
            let point = CGPoint(x: cos(a) * r, y: sin(a) * r)
            if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
        }
        return p
    }
    static func brushRing(radius: CGFloat, color: UIColor, width: CGFloat = 3) -> SKShapeNode {
        let n = SKShapeNode(path: ringPath(radius: radius, fraction: 0.97))
        n.strokeColor = color; n.lineWidth = width; n.lineCap = .round; return n
    }
}
