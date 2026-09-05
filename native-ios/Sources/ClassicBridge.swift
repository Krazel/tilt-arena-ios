import Foundation
import JavaScriptCore

struct ClassicFrame: Decodable {
    struct Player: Decodable {
        let x, y, vx, vy, angle: Double
        let bubble: Bool
        let spikesUntil, burnUntil: Double
    }
    struct Dot: Decodable {
        let id: Int
        let x, y: Double
        let telegraph, frozen, thawing: Bool
    }
    struct Orb: Decodable {
        let id: Int
        let x, y: Double
        let power: String
        let remaining: Double
    }
    struct Projectile: Decodable {
        let id: Int
        let x, y: Double
        let kind: String
        let angle: Double
    }
    struct Field: Decodable {
        let id: Int
        let x, y: Double
        let kind: String
        let remaining: Double
    }
    struct Event: Decodable {
        let kind: String
        let x, y, radius, angle, toX, toY: Double?
        let color, power: String?
        let value, bonus: Int?
    }
    let state: String
    let time: Double
    let score, combo, comboBase, pendingBonus, bestCombo, kills: Int
    let comboRemaining: Double
    let player: Player
    let enemies: [Dot]
    let pickups: [Orb]
    let projectiles: [Projectile]
    let fields: [Field]
    let events: [Event]
}

/// All calls happen on the SpriteKit/main thread. The bundled script has no
/// file/network capabilities and is also the exact module exercised by Node.
final class ClassicBridge {
    enum Failure: Error { case missingEngine, invalidFrame, script(String) }
    private let context: JSContext
    private let api: JSValue
    private let decoder = JSONDecoder()

    init(bundle: Bundle = .main) throws {
        guard let context = JSContext(),
              let url = bundle.url(forResource: "classic-core", withExtension: "js") else {
            throw Failure.missingEngine
        }
        self.context = context
        context.evaluateScript(try String(contentsOf: url, encoding: .utf8), withSourceURL: url)
        if let exception = context.exception { throw Failure.script(exception.toString()) }
        guard let value = context.objectForKeyedSubscript("ClassicAPI"), !value.isUndefined else {
            throw Failure.missingEngine
        }
        api = value
    }
    func create(seed: UInt32 = UInt32.random(in: 1...UInt32.max)) throws -> ClassicFrame {
        try decode(call("create", [seed]))
    }
    func tick(dt: Double, x: Double, y: Double) throws -> ClassicFrame {
        try decode(call("tick", [dt, x, y]))
    }
    func pause() throws { _ = try call("pause", []) }
    func resume() throws { _ = try call("resume", []) }
    func finish() throws -> ClassicFrame { try decode(call("finish", [])) }
    func tilt(gx: Double, gy: Double, nx: Double, ny: Double,
              orientation: String, sensitivity: Double) throws -> (Double, Double) {
        let result = try call("tilt", [gx, gy, nx, ny, orientation, sensitivity])
        guard let x = result.forProperty("x")?.toDouble(),
              let y = result.forProperty("y")?.toDouble(), x.isFinite, y.isFinite else {
            throw Failure.invalidFrame
        }
        return (x, y)
    }
    private func call(_ name: String, _ args: [Any]) throws -> JSValue {
        context.exception = nil
        let result = api.invokeMethod(name, withArguments: args)
        if let exception = context.exception { throw Failure.script(exception.toString()) }
        guard let result = result else { throw Failure.invalidFrame }
        return result
    }
    private func decode(_ value: JSValue) throws -> ClassicFrame {
        guard let text = value.toString(), let data = text.data(using: .utf8) else {
            throw Failure.invalidFrame
        }
        return try decoder.decode(ClassicFrame.self, from: data)
    }
}
