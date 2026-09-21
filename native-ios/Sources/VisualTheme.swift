import Foundation

/// Presentation only. Never changes the engine, records, input or saved posture.
enum VisualTheme: String, CaseIterable, Identifiable {
    case inkTide, classic
    var id: String { rawValue }
    var title: String { self == .inkTide ? "Ink Tide" : GameText.originalStyle }
    static let key = "classic.visualTheme"
    static func read(defaults: UserDefaults = .standard) -> VisualTheme {
        VisualTheme(rawValue: defaults.string(forKey: key) ?? "") ?? .inkTide
    }
    func save(defaults: UserDefaults = .standard) { defaults.set(rawValue, forKey: Self.key) }
}
