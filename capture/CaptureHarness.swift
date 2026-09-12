import Foundation
import UIKit

// Copied only into the temporary simulator capture target by prepare.py.
final class CaptureHarness {
    static let enabled = ProcessInfo.processInfo.arguments.contains("--capture-gameplay")
    static let seed: UInt32 = {
        let arg = ProcessInfo.processInfo.arguments.first { $0.hasPrefix("--capture-seed=") }
        return UInt32(arg?.split(separator: "=").last ?? "2") ?? 2
    }()
    static let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private var file: FileHandle?
    private var started = false, finished = false
    private var startWall = 0.0
    static func waitForStart(_ action: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if FileManager.default.fileExists(atPath: directory.appendingPathComponent("capture-go").path) {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: action)
            }
        }
    }
    func start(bounds: CGRect, screen: CGSize) {
        guard Self.enabled, !started else { return }
        started = true; startWall = Date().timeIntervalSince1970
        let url = Self.directory.appendingPathComponent("capture-frames.ndjson")
        FileManager.default.createFile(atPath: url.path, contents: nil)
        file = try? FileHandle(forWritingTo: url)
        let info: [String: Any] = ["version": "0.3.9", "build": "1", "seed": Self.seed,
            "startedWall": startWall, "simulator": true, "spawning": true,
            "fixtures": false, "control": "CaptureDriver snapshot-only simulated input",
            "bounds": ["left":bounds.minX,"right":bounds.maxX,"bottom":bounds.minY,"top":bounds.maxY],
            "screenPoints": [screen.width,screen.height], "screenScale": UIScreen.main.scale]
        save(info, name: "capture-start.json")
    }
    func record(_ frame: ClassicFrame, raw: String, input: (Double, Double), dt: Double) {
        guard started, !finished else { return }
        let wall = Date().timeIntervalSince1970
        let line = "{\"wall\":\(wall),\"dt\":\(dt),\"input\":[\(input.0),\(input.1)],\"frame\":\(raw)}\n"
        if let data = line.data(using: .utf8) { file?.write(data) }
        if frame.time >= 65 || frame.state != "running" {
            finished = true; try? file?.close()
            save(["endedWall":wall,"elapsedWall":wall-startWall,"gameTime":frame.time,
                "score":frame.score,"kills":frame.kills,"state":frame.state], name:"capture-done.json")
        }
    }
    private func save(_ value: [String: Any], name: String) {
        if let data = try? JSONSerialization.data(withJSONObject:value, options:.prettyPrinted) {
            try? data.write(to:Self.directory.appendingPathComponent(name), options:.atomic)
        }
    }
}
