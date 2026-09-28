import XCTest

/// Drives the existing simulator binary through its real UI. No scene fixtures.
final class StoreCaptureTests: XCTestCase {
    func testStoreScreenshotsInBothLanguages() {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .landscapeLeft
        for language in ["en", "es"] {
            for mode in ["classic", "hard"] {
                let app = XCUIApplication()
                app.launchArguments = ["--theme-ink-qa", "-AppleLanguages", "(\(language))",
                    "-AppleLocale", language == "es" ? "es_ES" : "en_US"]
                app.launch()
                XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 15))
                app.buttons["mode-\(mode)"].tap()
                app.buttons["posture-normal"].tap()
                capture("store-\(language)-\(mode)-menu")
                app.buttons["play"].tap()
                let arena = app.otherElements["arena-running"]
                XCTAssertTrue(arena.waitForExistence(timeout: 5))
                Thread.sleep(forTimeInterval: 1.0)
                if arena.exists { capture("store-\(language)-\(mode)-play-01") }
                // Existing simulator drag input; spawning and collisions stay active.
                for step in 0..<4 {
                    guard arena.exists else { break }
                    // Anchor gestures to the app, which still exists if death happens
                    // between the running-state check and event synthesis.
                    let a = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                    let offsets = [CGVector(dx: 0.62, dy: 0.45), CGVector(dx: 0.48, dy: 0.36),
                                   CGVector(dx: 0.38, dy: 0.52), CGVector(dx: 0.52, dy: 0.62)]
                    a.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: offsets[step]),
                            withVelocity: .slow, thenHoldForDuration: 0.2)
                    Thread.sleep(forTimeInterval: 0.4)
                    if arena.exists { capture("store-\(language)-\(mode)-play-0\(step + 2)") }
                }
                app.terminate()
            }
        }
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
