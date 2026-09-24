import SpriteKit
import UIKit

/// Literal drawings; only Wave uses the replacement symbol requested in 0.5.8.
enum ApprovedOrbArt {
    struct Region: Decodable {
        let crop: [Int]
        let mask: [[Double]]
        let displaySize: Double
    }
    struct Manifest: Decodable { let regions: [String: Region] }
    static let regions: [String: Region] = {
        guard let url = Bundle.main.url(forResource: "approved-orbs", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let manifest = try? JSONDecoder().decode(Manifest.self, from: data) else { return [:] }
        return manifest.regions
    }()
    private static let textures: [String: SKTexture] = {
        guard let image = UIImage(named: "ink-tide-approved-orbs")?.cgImage else { return [:] }
        return regions.compactMapValues { region in
            let c = region.crop
            guard let cell = image.cropping(to: CGRect(x: c[0], y: c[1], width: c[2], height: c[3])) else { return nil }
            return SKTexture(cgImage: cell)
        }
    }()
    private static let waveTexture: SKTexture? = {
        guard let image = UIImage(named: "ink-wave-orb-v058")?.cgImage,
              let region = regions["wave"] else { return nil }
        let c = region.crop
        guard let cell = image.cropping(to: CGRect(x: c[0], y: c[1], width: c[2], height: c[3])) else { return nil }
        return SKTexture(cgImage: cell)
    }()
    static func node(for power: String) -> SKNode? {
        guard let region = regions[power], let texture = textures[power] else { return nil }
        let size = CGFloat(region.displaySize) * 42 / 56
        let path = CGMutablePath()
        for (index, p) in region.mask.enumerated() {
            let point = CGPoint(x: (p[0] / 256 - 0.5) * Double(size), y: (0.5 - p[1] / 256) * Double(size))
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        let silhouette = SKShapeNode(path: path)
        silhouette.fillColor = .white; silhouette.strokeColor = .clear
        let root = SKCropNode(); root.name = "approved-orb-\(power)"; root.maskNode = silhouette
        let art = SKSpriteNode(texture: power == "wave" ? waveTexture ?? texture : texture); art.size = CGSize(width: size, height: size)
        root.addChild(art)
        return root
    }
}
