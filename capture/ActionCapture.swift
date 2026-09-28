import Foundation
import SpriteKit
import UIKit

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
    private var index = 0

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
            } catch { save(["error": String(describing: error)], "capture-error.json"); timer.invalidate() }
        }
    }
    func nextInput() -> (Double, Double) {
        guard index < Self.configuration.inputs.count else { return (0,0) }
        let input = Self.configuration.inputs[index]; index += 1
        return (input[0], input[1])
    }
    func record(_ frame: ClassicFrame, raw: String, scene: ClassicScene) {
        guard Self.enabled else { return }
        if frame.state != "running" {
            scene.view?.isPaused = true
            Self.save(["error":"Run ended before target", "step":index-1,"time":frame.time], "capture-error.json")
            return
        }
        guard let shot = Self.configuration.shots.first(where: { $0.step == index-1 }) else { return }
        // Freeze the already rendered state; do not pause, mutate or advance the engine.
        scene.view?.isPaused = true
        try? Data(raw.utf8).write(to: Self.directory.appendingPathComponent("capture-\(shot.name).json"), options: .atomic)
        Self.save(["name":shot.name,"step":shot.step], "capture-request.json")
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak scene] timer in
            let signal = Self.directory.appendingPathComponent("capture-resume")
            if FileManager.default.fileExists(atPath: signal.path) {
                try? FileManager.default.removeItem(at: signal)
                scene?.view?.isPaused = false
                timer.invalidate()
            }
        }
    }
    private static func save(_ value: [String: Any], _ name: String) {
        if let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted]) {
            try? data.write(to: directory.appendingPathComponent(name), options: .atomic)
        }
    }
}
