import Foundation
import SpriteKit
import UIKit
import Metal

// Simulator capture adapter only. Never part of the distributed target.
final class ActionCapture {
    struct Shot: Decodable { let step: Int; let name: String }
    struct Configuration: Decodable {
        let seed: UInt32
        let inputs: [[Double]]
        let shots: [Shot]
    }
    static let enabled = ProcessInfo.processInfo.arguments.contains("--capture-action")
    static let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static var configuration: Configuration!
    static var finished = false
    static var pendingShot: Shot?
    static var deliveredFrames = 0
    private var index = 0
    private var previousTime: TimeInterval?
    private var actionElapsed = 0.0
    private var previousActionElapsed = 0.0
    private var maxActionStepError = 0.0
    private var maxClockError = 0.0
    private var measuredFrames = 0

    func beginFrame(_ time: TimeInterval, scene: ClassicScene) -> Double {
        Self.deliveredFrames += 1
        let dt = 1.0 / 60
        if previousTime == nil {
            scene.speed = 1
            // Invisible clock probe inherits exactly the same scene clock as VFX.
            let probe = SKNode(); scene.addChild(probe)
            probe.run(.customAction(withDuration: 1000) { [weak self] _, elapsed in
                self?.actionElapsed = Double(elapsed)
            })
        }
        previousTime = time
        return dt
    }

    static func waitForStart(scene: ClassicScene) {
        guard enabled else { return }
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak scene] timer in
            guard let scene = scene, let view = scene.view else { timer.invalidate(); return }
            let b = scene.arenaBounds
            let ready: [String: Any] = ["bounds": ["left": b.minX, "right": b.maxX, "bottom": b.minY, "top": b.maxY],
                "points": [view.bounds.width, view.bounds.height], "scale": UIScreen.main.scale]
            save(ready, "capture-ready.json")
            guard FileManager.default.fileExists(atPath: directory.appendingPathComponent("capture-go").path) else { return }
            do {
                configuration = try JSONDecoder().decode(Configuration.self, from: Data(contentsOf: directory.appendingPathComponent("capture-config.json")))
                timer.invalidate()
                scene.session?.posture = .normal
                scene.session?.mode = .classic
                scene.play(restart: true)
                drive(scene: scene, view: view)
            } catch { save(["error": String(describing: error)], "capture-error.json"); timer.invalidate() }
        }
    }
    func nextInput() -> (Double, Double) {
        guard index < Self.configuration.inputs.count else { return (0,0) }
        let input = Self.configuration.inputs[index]; index += 1
        return (input[0], input[1])
    }
    func record(_ frame: ClassicFrame, raw: String, scene: ClassicScene) {
        guard Self.enabled, !Self.finished, index > 0 else { return }
        if index > 2 {
            maxActionStepError = max(maxActionStepError, abs(actionElapsed - previousActionElapsed - 1.0 / 60))
            maxClockError = max(maxClockError, abs(actionElapsed - Double(index - 1) / 60))
            measuredFrames += 1
        }
        previousActionElapsed = actionElapsed
        if frame.state != "running" {
            Self.finished = true
            scene.view?.isPaused = true
            Self.save(["error":"Run ended before target", "step":index-1,"time":frame.time], "capture-error.json")
            return
        }
        guard let shot = Self.configuration.shots.first(where: { $0.step == index-1 }) else { return }
        Self.save(["actionElapsed": actionElapsed, "engineElapsed": frame.time,
                   "expectedActionElapsed": Double(index - 1) / 60,
                   "maxActionStepError": maxActionStepError, "maxClockError": maxClockError,
                   "measuredFrames": measuredFrames], "capture-\(shot.name)-timing.json")
        Self.finished = true
        try? Data(raw.utf8).write(to: Self.directory.appendingPathComponent("capture-\(shot.name).json"), options: .atomic)
        if maxActionStepError >= 0.035 || maxClockError >= 0.035 {
            Self.save(["error":"Native action clock drift", "step":index-1,
                       "maxClockError":maxClockError,"maxActionStepError":maxActionStepError], "capture-error.json")
        } else { Self.pendingShot = shot }
    }
    static func drive(scene: ClassicScene, view: SKView) {
        // Warm the same production textures before transferring ownership to SKRenderer.
        scene.captureWarmTextures(in: view)
        view.isPaused = true
        view.presentScene(nil)
        scene.isPaused = false
        guard let device = MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue() else {
            save(["error":"No Metal device/queue"], "capture-error.json"); return
        }
        let renderer = SKRenderer(device: device); renderer.scene = scene
        renderer.ignoresSiblingOrder = view.ignoresSiblingOrder
        renderer.shouldCullNonVisibleNodes = view.shouldCullNonVisibleNodes
        let width = Int(view.bounds.width * UIScreen.main.scale)
        let height = Int(view.bounds.height * UIScreen.main.scale)
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
        descriptor.usage = [.renderTarget, .shaderRead]; descriptor.storageMode = .shared
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            save(["error":"No Metal target"], "capture-error.json"); return
        }
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = texture
        pass.colorAttachments[0].loadAction = .clear; pass.colorAttachments[0].storeAction = .store
        pass.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        var step = 0
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
            autoreleasepool {
                renderer.update(atTime: Double(step) / 60)
                if step % 120 == 0 {
                    save(["rendererSteps":step,"sceneFrames":deliveredFrames,"scenePaused":scene.isPaused], "capture-progress.json")
                    if step > 0 && deliveredFrames == 0 {
                        save(["error":"Renderer did not update scene"], "capture-error.json"); timer.invalidate(); return
                    }
                }
                guard let buffer = queue.makeCommandBuffer() else {
                    save(["error":"No command buffer"], "capture-error.json"); timer.invalidate(); return
                }
                renderer.render(withViewport: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)), commandBuffer: buffer, renderPassDescriptor: pass)
                buffer.commit(); buffer.waitUntilCompleted(); step += 1
                if buffer.status == .error {
                    save(["error":"Metal render failed"], "capture-error.json"); timer.invalidate(); return
                }
                guard finished else { return }
                timer.invalidate()
                guard let shot = pendingShot else { return }
                var bytes = [UInt8](repeating: 0, count: width * height * 4)
                texture.getBytes(&bytes, bytesPerRow: width * 4, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
                let data = Data(bytes)
                let bitmap = CGBitmapInfo.byteOrder32Little.union(CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue))
                guard let provider = CGDataProvider(data: data as CFData),
                      let image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
                                          space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: bitmap,
                                          provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent),
                      let png = UIImage(cgImage: image).pngData() else {
                    save(["error":"Native PNG encoding failed"], "capture-error.json"); return
                }
                do {
                    try png.write(to: directory.appendingPathComponent("capture-\(shot.name).png"), options: .atomic)
                    save(["name":shot.name,"step":shot.step], "capture-request.json")
                } catch { save(["error":String(describing:error)], "capture-error.json") }
            }
        }
    }
    private static func save(_ value: [String: Any], _ name: String) {
        if let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted]) {
            try? data.write(to: directory.appendingPathComponent(name), options: .atomic)
        }
    }
}
