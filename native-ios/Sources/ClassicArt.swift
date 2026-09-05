import SpriteKit
import UIKit

extension UIColor {
    convenience init(hex: String) {
        let value = UInt32(hex.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 0xffffff
        self.init(red: CGFloat((value >> 16) & 255)/255, green: CGFloat((value >> 8) & 255)/255,
                  blue: CGFloat(value & 255)/255, alpha: 1)
    }
}

/// Original vector geometry. Cached as textures by the scene; no imported game art.
enum ClassicArt {
    static let colors = ["nuke":"ffb52a","wave":"ba71ee","missiles":"f7e36b","frost":"70dce9",
        "bubble":"7bde83","spikes":"6c9ce8","vortex":"ee77bc","lightning":"eeefff","burn":"ff784c"]
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
        if style == "dot" { return circle(7,fill:UIColor(hex:"ff5658"),stroke:UIColor(hex:"fff5d7"),width:2) }
        if style == "arrow" || style == "missileShot" {
            let path=CGMutablePath();path.move(to:CGPoint(x:16,y:0));path.addLine(to:CGPoint(x:-12,y:11))
            path.addLine(to:CGPoint(x:-6,y:0));path.addLine(to:CGPoint(x:-12,y:-11));path.closeSubpath()
            let shape=SKShapeNode(path:path);shape.fillColor=UIColor(hex:style == "arrow" ? "f7ffe5" : "ffe57a")
            shape.strokeColor=UIColor(hex:"243815");shape.lineWidth=2
            if style == "missileShot" { shape.setScale(0.4) };return shape
        }
        if style == "waveShot" {
            let path=CGMutablePath();path.move(to:CGPoint(x:-10,y:-48))
            path.addQuadCurve(to:CGPoint(x:-10,y:48),control:CGPoint(x:24,y:0))
            let n=SKShapeNode(path:path);n.strokeColor=UIColor(hex:"e6b6ff");n.lineWidth=9;n.glowWidth=3;return n
        }
        if style == "fire" { return circle(22,fill:UIColor(hex:"ff953d").withAlphaComponent(0.65),stroke:UIColor(hex:"ffd87a")) }
        let root=SKNode(),color=UIColor(hex:colors[style] ?? "ee77bc")
        if style == "vortexField" {
            for i in 0..<4 {
                let ring=circle(CGFloat(16+i*14),fill:.clear,stroke:color.withAlphaComponent(CGFloat(0.8-Double(i)*0.16)),width:3)
                ring.xScale=1-0.12*CGFloat(i);root.addChild(ring)
            }
            root.addChild(circle(14,fill:UIColor(hex:"261c31"),stroke:color));return root
        }
        root.addChild(circle(18,fill:color.withAlphaComponent(0.28),stroke:UIColor(hex:"f2ffe0")))
        root.addChild(circle(14.5,fill:color.withAlphaComponent(0.65),stroke:color,width:1))
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
                ctx.drawLinearGradient(gradient,start:.zero,end:CGPoint(x:340,y:640),options:[])
            }
            ctx.setStrokeColor(UIColor(hex:"d1ee80").withAlphaComponent(0.07).cgColor);ctx.setLineWidth(3)
            for i in 0..<9 {let r=CGFloat(40+i*37);ctx.strokeEllipse(in:CGRect(x:610-r,y:250-r,width:r*2,height:r*2))}
            ctx.setLineWidth(1)
            for i in 0..<16 {ctx.move(to:CGPoint(x:0,y:640));ctx.addLine(to:CGPoint(x:CGFloat(i)*100,y:0));ctx.strokePath()}
        }
        return SKTexture(image:image)
    }
}
