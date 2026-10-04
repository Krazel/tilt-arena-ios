import Foundation

enum TiltPosture: String, CaseIterable, Identifiable {
    case custom, normal, inclined
    var id: String { rawValue }
    var title: String {
        switch self {
        case .normal: return GameLanguage.current == .spanish ? "Normal" : "Normal"
        case .inclined: return GameLanguage.current == .spanish ? "Inclinado" : "Inclined"
        case .custom: return GameLanguage.current == .spanish ? "Calibrar" : "Calibrate"
        }
    }
    var symbol: String {
        switch self { case .normal: return "iphone.gen3"; case .inclined: return "iphone.gen3.radiowaves.left.and.right"; case .custom: return "scope" }
    }
    var description: String {
        switch self {
        case .normal: return GameLanguage.current == .spanish ? "Sujeta el iPhone a unos 45° sobre la mesa." : "Hold the iPhone at about 45° above the table."
        case .inclined: return GameLanguage.current == .spanish ? "iPhone plano, pantalla hacia arriba, como sobre una mesa." : "Keep the iPhone flat, screen up, like it is on a table."
        case .custom: return GameLanguage.current == .spanish ? "Guarda el ángulo que te resulte más cómodo." : "Save the angle that feels most comfortable."
        }
    }
}

/// Neutral is stored in screen axes, so a 180° turn does not require a new sample.
struct TiltProfile {
    var screenX: Double
    var screenY: Double
    // Screen-normal gravity, positive face up and negative face down.
    var screenZ: Double
    init(screenX: Double = 0, screenY: Double = -sin(Double.pi / 4), screenZ: Double? = nil) {
        self.screenX = screenX; self.screenY = screenY
        // Older saved profiles only contain X/Y and assumed face up.
        self.screenZ = screenZ ?? sqrt(max(0, 1 - screenX * screenX - screenY * screenY))
    }
    static func saved(defaults: UserDefaults) -> TiltProfile {
        let legacy = TiltProfile(screenX: defaults.double(forKey: "classic.neutralX"),
                    screenY: defaults.double(forKey: "classic.neutralY"),
                    screenZ: defaults.object(forKey: "classic.neutralZ") as? Double)
        return pitchOnly(y: legacy.screenY, z: legacy.screenZ) ?? preset(.normal)
    }
    private static func pitchOnly(y: Double, z: Double) -> TiltProfile? {
        let length = hypot(y, z)
        guard length.isFinite, length > 0.01 else { return nil }
        return TiltProfile(screenX: 0, screenY: y / length, screenZ: z / length)
    }
    func save(defaults: UserDefaults) {
        defaults.set(0.0, forKey: "classic.neutralX")
        defaults.set(screenY, forKey: "classic.neutralY")
        defaults.set(screenZ, forKey: "classic.neutralZ")
    }
    static func preset(_ posture: TiltPosture) -> TiltProfile {
        TiltProfile(screenX: 0, screenY: -sin((posture == .inclined ? 0.0 : 45.0) * .pi / 180))
    }
    static func initialPosture(defaults: UserDefaults) -> TiltPosture {
        // New preset semantics: start with calibration once, then remember the
        // user's subsequent explicit choice. Keep their saved neutral intact.
        guard defaults.integer(forKey: "classic.postureRevision") >= 2 else { return .custom }
        return TiltPosture(rawValue: defaults.string(forKey: "classic.posture") ?? "custom") ?? .custom
    }
    static func sampled(x: Double, y: Double, landscapeRight: Bool) -> TiltProfile {
        TiltProfile(screenX: landscapeRight ? -y : y, screenY: landscapeRight ? x : -x)
    }
    /// A single fresh, filtered Core Motion gravity reading defines the neutral.
    /// Reject missing/stale/invalid readings instead of saving a false posture.
    static func capture(x: Double, y: Double, z: Double, timestamp: Double,
                        now: Double, landscapeRight: Bool) -> TiltProfile? {
        guard [x, y, z, timestamp, now].allSatisfy({ $0.isFinite }),
              now >= timestamp, now - timestamp <= 0.25,
              (0.8...1.2).contains(sqrt(x*x + y*y + z*z)) else { return nil }
        // Capture pitch only. Lateral tilt always steers relative to a level
        // phone, even if the player rolls it while pressing Calibrate.
        return pitchOnly(y: landscapeRight ? x : -x, z: -z)
    }
    func deviceNeutral(landscapeRight: Bool) -> (x: Double, y: Double) {
        landscapeRight ? (screenY, -screenX) : (-screenY, screenX)
    }
    func motionDelta(x: Double, y: Double, z: Double, landscapeRight: Bool) -> (x: Double, y: Double) {
        let sx = landscapeRight ? -y : y, sy = landscapeRight ? x : -x
        // Mirror the normal for a face-down neutral so lowering the same screen
        // edge keeps the same direction. Keep this sign fixed until recalibration.
        let facing = screenZ < 0 ? -1.0 : 1.0
        let pitch = atan2(sy, -z * facing) - atan2(screenY, screenZ * facing)
        let roll = atan2(sx, hypot(sy, z))
        let dx = sin(roll), dy = sin(pitch)
        return landscapeRight ? (dy, -dx) : (-dy, dx)
    }
}
