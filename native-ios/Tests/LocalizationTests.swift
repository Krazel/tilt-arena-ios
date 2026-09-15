import XCTest
@testable import TiltArena

final class LocalizationTests: XCTestCase {
    func testSpanishPreferredLanguagesUseCastilian() {
        XCTAssertEqual(GameLanguage.resolve(preferredLanguages: ["es-ES", "en-US"]), .spanish)
        XCTAssertEqual(GameLanguage.resolve(preferredLanguages: ["es-MX"]), .spanish)
    }

    func testNonSpanishAndMissingPreferencesUseEnglishFallback() {
        XCTAssertEqual(GameLanguage.resolve(preferredLanguages: ["en-US", "es-ES"]), .english)
        XCTAssertEqual(GameLanguage.resolve(preferredLanguages: ["fr-FR"]), .english)
        XCTAssertEqual(GameLanguage.resolve(preferredLanguages: []), .english)
    }
}
