import Foundation

enum TiltPosture: String, CaseIterable, Identifiable {
    case normal, inclined, custom
    var id: String { rawValue }
    var title: String {
        switch self { case .normal: return "Normal"; case .inclined: return "Inclinado"; case .custom: return "Personalizado" }
    }
    var symbol: String {
        switch self { case .normal: return "iphone.gen3"; case .inclined: return "iphone.gen3.radiowaves.left.and.right"; case .custom: return "scope" }
    }
    var description: String {
        switch self {
        case .normal: return "Sujeta el iPhone a unos 45° sobre la mesa."
        case .inclined: return "Para jugar más recostado, con el iPhone a unos 70°."
        case .custom: return "Guarda el ángulo que te resulte más cómodo."
        }
    }
}

/// Neutral is stored in screen axes, so a 180° turn does not require a new sample.
struct TiltProfile {
    var screenX = 0.0
    var screenY = -sin(Double.pi / 4)
    static func preset(_ posture: TiltPosture) -> TiltProfile {
        TiltProfile(screenX: 0, screenY: -sin((posture == .inclined ? 70.0 : 45.0) * .pi / 180))
    }
    static func sampled(x: Double, y: Double, landscapeRight: Bool) -> TiltProfile {
        TiltProfile(screenX: landscapeRight ? -y : y, screenY: landscapeRight ? x : -x)
    }
    func deviceNeutral(landscapeRight: Bool) -> (x: Double, y: Double) {
        landscapeRight ? (screenY, -screenX) : (-screenY, screenX)
    }
    func motionDelta(x: Double, y: Double, z: Double, landscapeRight: Bool) -> (x: Double, y: Double) {
        let sx = landscapeRight ? -y : y, sy = landscapeRight ? x : -x
        let neutralZ = sqrt(max(0, 1 - screenX * screenX - screenY * screenY))
        let pitch = atan2(sy, -z) - atan2(screenY, neutralZ)
        let roll = atan2(sx, hypot(sy, z)) - atan2(screenX, hypot(screenY, neutralZ))
        let dx = sin(roll), dy = sin(pitch)
        return landscapeRight ? (dy, -dx) : (-dy, dx)
    }
}
