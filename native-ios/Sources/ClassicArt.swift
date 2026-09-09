import SpriteKit
import UIKit
import ImageIO

extension UIColor {
    convenience init(hex: String) {
        let value = UInt32(hex.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 0xffffff
        self.init(red: CGFloat((value >> 16) & 255)/255, green: CGFloat((value >> 8) & 255)/255,
                  blue: CGFloat(value & 255)/255, alpha: 1)
    }
}

/// ChatGPT Images sprite bases with native glyphs and animation geometry.
enum ClassicArt {
    private static func imageTexture(_ name: String, maximum: Int) -> SKTexture {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0,
                [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceThumbnailMaxPixelSize: maximum,
                 kCGImageSourceCreateThumbnailWithTransform: true] as CFDictionary) else {
            preconditionFailure("Missing generated sprite: \(name)")
        }
        return SKTexture(cgImage: image)
    }
    static let orb = imageTexture("orb-glass-v03", maximum: 192)
    static let spark = imageTexture("energy-spark-v03", maximum: 128)
    static let colors = ["nuke":"ffb52a","wave":"ba71ee","missiles":"f7e36b","frost":"70dce9",
        "bubble":"7bde83","spikes":"6c9ce8","vortex":"ee77bc","lightning":"eeefff","burn":"ff784c",
        "boomerang":"ffc06a"]
    static func star(radius: CGFloat, inner: CGFloat, points: Int) -> CGPath {
        let path=CGMutablePath()
        for index in 0..<(points*2) {
            let angle=CGFloat(index)*CGFloat.pi/CGFloat(points),r=index%2 == 0 ? radius : inner
            let p=CGPoint(x:cos(angle)*r,y:sin(angle)*r)
            if index == 0 { path.move(to:p) } else { path.addLine(to:p) }
        }
        path.closeSubpath();return path
    }
    private static func line(_ points: [CGPoint], color: UIColor = .white, width: CGFloat = 2.5) -> SKShapeNode {
        let p=CGMutablePath()
        for (index,point) in points.enumerated() { if index == 0 {p.move(to:point)}else{p.addLine(to:point)} }
        let n=SKShapeNode(path:p);n.strokeColor=color;n.lineWidth=width;n.lineCap = .round;n.lineJoin = .round
        return n
    }
    private static func circle(_ radius: CGFloat, fill: UIColor, stroke: UIColor, width: CGFloat = 2) -> SKShapeNode {
        let n=SKShapeNode(circleOfRadius:radius);n.fillColor=fill;n.strokeColor=stroke;n.lineWidth=width;return n
    }
    static func node(style: String) -> SKNode {
        if style == "boomerangShot" {
            let root = SKNode()
            // Two swept blades around a luminous hub: readable in every rotation.
            for angle in [CGFloat(0), .pi] {
                let path = CGMutablePath(); path.move(to: CGPoint(x: 0, y: -4))
                path.addQuadCurve(to: CGPoint(x: 28, y: 6), control: CGPoint(x: 22, y: -18))
                path.addLine(to: CGPoint(x: 9, y: 3))
                path.addQuadCurve(to: CGPoint(x: -4, y: 4), control: CGPoint(x: 6, y: 11))
                path.closeSubpath()
                let blade = SKShapeNode(path: path); blade.fillColor = UIColor(hex: "ffc06a")
                blade.strokeColor = UIColor(hex: "fff5d8"); blade.lineWidth = 2
                blade.zRotation = angle; root.addChild(blade)
            }
            root.addChild(circle(6, fill: UIColor(hex: "fffce0"), stroke: UIColor(hex: "815824")))
            return root
        }
        if style == "dot" { return circle(10, fill: UIColor(hex: "ff5658"), stroke: UIColor(hex: "fff5d7"), width: 2) }
        if style == "arrow" || style == "missileShot" {
            let path=CGMutablePath();path.move(to:CGPoint(x:20,y:0));path.addLine(to:CGPoint(x:-16,y:14))
            path.addLine(to:CGPoint(x:-8,y:0));path.addLine(to:CGPoint(x:-16,y:-14));path.closeSubpath()
            let shape=SKShapeNode(path:path);shape.fillColor=UIColor(hex:style == "arrow" ? "f7ffe5" : "ffe57a")
            shape.strokeColor=UIColor(hex:"243815");shape.lineWidth=2
            if style == "missileShot" { shape.setScale(0.4) };return shape
        }
        if style == "waveShot" {
            let root = SKNode()
            // Approved A: three smooth, tapered crescents; leading edge is +X.
            for i in (0..<3).reversed() {
                let x = CGFloat(-i * 15), r = CGFloat(48 - i * 5)
                for (thickness, tint) in [(CGFloat(22), "8542ce"), (CGFloat(13), "ba71ee"), (CGFloat(4), "f5e5ff")] {
                    let path = CGMutablePath(); path.move(to: CGPoint(x: x - 24, y: -r))
                    path.addQuadCurve(to: CGPoint(x: x - 24, y: r), control: CGPoint(x: x + 54, y: 0))
                    path.addQuadCurve(to: CGPoint(x: x - 24, y: -r), control: CGPoint(x: x + 54 - thickness, y: 0))
                    path.closeSubpath()
                    let blade = SKShapeNode(path: path); blade.fillColor = UIColor(hex: tint)
                    blade.strokeColor = .clear; blade.alpha = thickness == 22 ? 0.55 : 1
                    root.addChild(blade)
                }
            }
            return root
        }
        if style == "fire" {
            let root = SKNode()
            // Approved A: pointed orange flame tongues behind a white-hot core.
            for (scale, tint) in [(CGFloat(1), "ef5321"), (CGFloat(0.72), "ffb324"), (CGFloat(0.36), "fff3ba")] {
                let path = CGMutablePath(); path.move(to: CGPoint(x: 22, y: 0))
                for p in [CGPoint(x: -40, y: 19), CGPoint(x: -24, y: 4), CGPoint(x: -48, y: 7),
                          CGPoint(x: -30, y: -2), CGPoint(x: -43, y: -17), CGPoint(x: -12, y: -7)] {
                    path.addLine(to: CGPoint(x: p.x, y: p.y * scale))
                }
                path.closeSubpath(); let flame = SKShapeNode(path: path)
                flame.fillColor = UIColor(hex: tint); flame.strokeColor = .clear; root.addChild(flame)
            }
            return root
        }
        let root=SKNode(),color=UIColor(hex:colors[style] ?? "ee77bc")
        if style == "vortexField" {
            for arm in 0..<3 {
                for (width, tint, opacity) in [(CGFloat(28), "64299c", CGFloat(0.45)), (CGFloat(17), "b54ff1", CGFloat(0.85)), (CGFloat(5), "eed2ff", CGFloat(0.95))] {
                    let path = CGMutablePath()
                    for side in [CGFloat(1), CGFloat(-1)] {
                        let indices = side > 0 ? Array(0...64) : Array((0...64).reversed())
                        for i in indices {
                            let t = CGFloat(i) / 64, a = t * .pi * 1.5 + CGFloat(arm) * .pi * 2 / 3
                            let r = 23 + t * 165 + side * sin(t * .pi) * width
                            let p = CGPoint(x: cos(a) * r, y: sin(a) * r)
                            if side > 0 && i == 0 { path.move(to: p) } else { path.addLine(to: p) }
                        }
                    }
                    path.closeSubpath(); let spiral = SKShapeNode(path: path)
                    spiral.fillColor = UIColor(hex: tint); spiral.strokeColor = .clear
                    spiral.alpha = opacity; root.addChild(spiral)
                }
            }
            let rim = circle(26, fill: UIColor(hex: "10051d"), stroke: UIColor(hex: "c47aff"), width: 3)
            rim.glowWidth = 3; root.addChild(rim)
            root.addChild(circle(21, fill: UIColor(hex: "090211"), stroke: .clear, width: 0));return root
        }
        let housing = SKSpriteNode(texture: orb); housing.size = CGSize(width: 42, height: 42)
        housing.color = color; housing.colorBlendFactor = 0.72; root.addChild(housing)
        root.addChild(circle(12,fill:UIColor(hex: "11200b").withAlphaComponent(0.65),stroke:.clear,width:0))
        switch style {
        case "nuke":
            root.addChild(circle(6,fill:color,stroke:.white))
            for i in 0..<8 {let a=CGFloat(i)*CGFloat.pi/4
                root.addChild(line([CGPoint(x:9*cos(a),y:9*sin(a)),CGPoint(x:12*cos(a),y:12*sin(a))],width:2))}
        case "wave":
            for x in [CGFloat(-6),CGFloat(2)] { root.addChild(line([CGPoint(x:x-2,y:-9),CGPoint(x:x+5,y:0),CGPoint(x:x-2,y:9)])) }
        case "missiles":
            for x in [CGFloat(-8),CGFloat(0),CGFloat(8)] {root.addChild(line([CGPoint(x:x-3,y:-7),CGPoint(x:x+2,y:7),CGPoint(x:x+4,y:2)],width:2))}
        case "frost":
            for i in 0..<3 {let a=CGFloat(i)*CGFloat.pi/3
                root.addChild(line([CGPoint(x:-11*cos(a),y:-11*sin(a)),CGPoint(x:11*cos(a),y:11*sin(a))],width:2))}
        case "bubble":root.addChild(circle(10,fill:.clear,stroke:.white))
        case "spikes":
            let n=SKShapeNode(path:star(radius:12,inner:6,points:8));n.strokeColor = .white;n.lineWidth=2;root.addChild(n)
        case "vortex":
            let path=CGMutablePath()
            for i in 0..<60 {let a=CGFloat(i)*0.17,r=CGFloat(i)*0.18,p=CGPoint(x:cos(a)*r,y:sin(a)*r)
                if i==0 {path.move(to:p)}else{path.addLine(to:p)}}
            let n=SKShapeNode(path:path);n.strokeColor = .white;n.lineWidth=2;root.addChild(n)
        case "lightning":root.addChild(line([CGPoint(x:6,y:12),CGPoint(x:-5,y:0),CGPoint(x:4,y:0),CGPoint(x:-6,y:-12)],width:3))
        case "burn":
            root.addChild(line([CGPoint(x:-8,y:-7),CGPoint(x:-7,y:2),CGPoint(x:-2,y:0),CGPoint(x:2,y:12),CGPoint(x:8,y:-7),CGPoint(x:-8,y:-7)]))
        case "boomerang":
            root.addChild(line([CGPoint(x:-10,y:7),CGPoint(x:2,y:2),CGPoint(x:7,y:-10),CGPoint(x:-1,y:-2),CGPoint(x:-10,y:7)],width:3))
        default:break
        }
        return root
    }
    static func background(size: CGSize) -> SKTexture {
        let renderer=UIGraphicsImageRenderer(size:size)
        let image=renderer.image { context in
            let ctx=context.cgContext
            let colors=[UIColor(hex:"354e17").cgColor,UIColor(hex:"77942c").cgColor] as CFArray
            if let gradient=CGGradient(colorsSpace:CGColorSpaceCreateDeviceRGB(),colors:colors,locations:[0,1]) {
                ctx.drawLinearGradient(gradient,start:.zero,end:CGPoint(x:size.width * 0.7,y:size.height),options:[.drawsBeforeStartLocation,.drawsAfterEndLocation])
            }
            ctx.setStrokeColor(UIColor(hex:"d1ee80").withAlphaComponent(0.07).cgColor);ctx.setLineWidth(3)
            for i in 0..<9 {let r=CGFloat(40+i*37);ctx.strokeEllipse(in:CGRect(x:size.width * 0.67-r,y:250-r,width:r*2,height:r*2))}
            ctx.setLineWidth(1)
            for i in 0..<20 {ctx.move(to:CGPoint(x:0,y:640));ctx.addLine(to:CGPoint(x:CGFloat(i)*size.width/16,y:0));ctx.strokePath()}
        }
        return SKTexture(image:image)
    }
}
