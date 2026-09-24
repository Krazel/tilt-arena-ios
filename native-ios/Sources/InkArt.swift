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
    /// Match the browser's source-in fill. SpriteKit colorBlendFactor multiplies
    /// the red source by blue and makes frozen dots nearly black instead.
    static let frozenAtlasImage: UIImage = {
        let source = UIImage(named: "ink-tide-sprites")!
        let format = UIGraphicsImageRendererFormat(); format.scale = 1; format.opaque = false
        return UIGraphicsImageRenderer(size: source.size, format: format).image { context in
            let rect = CGRect(origin: .zero, size: source.size)
            source.draw(in: rect)
            context.cgContext.setBlendMode(.sourceIn)
            context.cgContext.setFillColor(blue.cgColor)
            context.cgContext.fill(rect)
        }
    }()
    static let frozenDot = SKTexture(rect: CGRect(x: 0.25, y: 0.5, width: 0.25, height: 0.5),
                                    in: SKTexture(image: frozenAtlasImage))
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
    static let orbColors = ["nuke":"806326", "wave":"69556f", "missiles":"858252", "frost":"367582",
        "bubble":"526444", "spikes":"466277", "vortex":"76546a", "lightning":"657986", "burn":"975937", "boomerang":"796746", "laser":"85535c"]
    /// Recolor teal ink only; the authored cream rim and alpha remain untouched.
    /// Match the source luminance so every paper grain/highlight keeps its contrast.
    static func pigment(_ rgb: [Double], target: [Double]) -> [Double] {
        let mask = max(0, min(1, (min(rgb[1], rgb[2]) - rgb[0] - 0.015) / 0.09))
        let luma: ([Double]) -> Double = { 0.2126 * $0[0] + 0.7152 * $0[1] + 0.0722 * $0[2] }
        let scale = luma(rgb) / max(0.001, luma(target))
        return (0..<3).map { rgb[$0] * (1-mask) + min(1, target[$0] * scale) * mask }
    }
    private static let coloredOrbs: [String: SKTexture] = {
        guard let source = UIImage(named: "ink-tide-sprites")?.cgImage,
              let cell = source.cropping(to: CGRect(x: source.width/2, y: 0, width: source.width/4, height: source.height/2)) else { return [:] }
        let w = cell.width, h = cell.height
        return orbColors.mapValues { hex in
            var bytes = [UInt8](repeating: 0, count: w * h * 4)
            let color = UIColor(hex: hex); var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, alpha: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &alpha)
            let target = [Double(r), Double(g), Double(b)]
            return bytes.withUnsafeMutableBytes { buffer in
                guard let ctx = CGContext(data: buffer.baseAddress, width: w, height: h, bitsPerComponent: 8,
                    bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { return cells[2] }
                ctx.draw(cell, in: CGRect(x: 0, y: 0, width: w, height: h))
                let data = buffer.bindMemory(to: UInt8.self)
                for i in stride(from: 0, to: data.count, by: 4) {
                    let a = Double(data[i+3]); if a == 0 { continue }
                    let rgb = (0..<3).map { Double(data[i+$0]) / a }
                    let changed = pigment(rgb, target: target)
                    for c in 0..<3 { data[i+c] = UInt8(max(0, min(255, (changed[c] * a).rounded()))) }
                }
                guard let image = ctx.makeImage() else { return cells[2] }
                return SKTexture(cgImage: image)
            }
        }
    }()
    static func node(style: String) -> SKNode {
        if let approved = ApprovedOrbArt.node(for: style) { return approved }
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
            let root = SKNode(), orb = SKSpriteNode(texture: coloredOrbs[style] ?? cells[2])
            orb.size = CGSize(width: 60, height: 60)
            root.addChild(orb)
            // Keep the learned power symbols, with paper ink instead of glass.
            let original = ClassicArt.node(style: style)
            for child in Array(original.children.dropFirst(2)) {
                child.removeFromParent(); paperGlyph(child); root.addChild(child)
            }
            if style == "vortex" {
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
