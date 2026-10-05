import Foundation

/// Temporary visual comparison. No simulation settings depend on this value.
enum LaserStyle: String, CaseIterable, Identifiable {
    case current, plasma, inkBeam
    var id: String { rawValue }
    static let key = "classic.laserStyleTrial"
    var title: String {
        switch self {
        case .current: return GameLanguage.current == .spanish ? "Actual" : "Current"
        case .plasma: return "A"
        case .inkBeam: return "B"
        }
    }
    static func read(defaults: UserDefaults = .standard) -> LaserStyle { LaserStyle(rawValue: defaults.string(forKey: key) ?? "") ?? .current }
    func save(defaults: UserDefaults = .standard) { defaults.set(rawValue, forKey: Self.key) }
}
