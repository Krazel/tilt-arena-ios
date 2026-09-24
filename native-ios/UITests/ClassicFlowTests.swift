import XCTest

final class ClassicFlowTests: XCTestCase {
    func testFireRecoveryIndicatorAfterDash() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--theme-ink-qa", "--fire-recovery-qa"]
        app.launch(); XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
        capture("32-fire-recovery", app: app)
    }
    func testHUDRibbonsWithLargeNumbersInBothLanguages() {
        let app = XCUIApplication()
        for language in ["en", "es"] {
            app.launchArguments = ["--ui-testing", "--theme-ink-qa", "--visual-qa", "--hud-large-qa", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "es" ? "es_ES" : "en_US"]
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            capture("31-hud-large-\(language)", app: app)
            app.terminate()
        }
    }
    func testApprovedAudioCreditsAreAccessibleInBothLanguages() {
        let app = XCUIApplication()
        for language in ["en", "es"] {
            app.launchArguments = ["--ui-testing", "--theme-ink-qa", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "es" ? "es_ES" : "en_US"]
            app.launch()
            XCTAssertTrue(app.buttons["audio-credits"].waitForExistence(timeout: 10))
            app.buttons["audio-credits"].tap()
            let close = app.buttons[language == "es" ? "Cerrar" : "Close"]
            XCTAssertTrue(close.waitForExistence(timeout: 3))
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "PeriTune")).firstMatch.exists)
            capture("34-audio-credits-\(language)", app: app)
            close.tap(); XCTAssertTrue(app.buttons["play"].exists)
            app.terminate()
        }
    }
    func testIllustratedMenuAndConfirmedRunActionsInBothLanguagesAndThemes() {
        let app = XCUIApplication()
        for (language, theme) in [("en", "ink"), ("es", "ink"), ("en", "classic")] {
            app.launchArguments = ["--ui-testing", "--theme-\(theme)-qa", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "es" ? "es_ES" : "en_US"]
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["mode-classic"].tap(); app.buttons["posture-normal"].tap()
            capture("31-\(theme)-\(language)-main", app: app)
            app.buttons["play"].tap(); XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            pauseByTouch(app); capture("32-\(theme)-\(language)-pause", app: app)
            for id in ["restart", "main-menu"] {
                app.buttons[id].tap(); XCTAssertTrue(app.buttons["confirm-cancel"].waitForExistence(timeout: 3)); XCTAssertFalse(app.alerts.firstMatch.exists)
                capture("33-\(theme)-\(language)-\(id)-confirm", app: app)
                app.buttons["confirm-cancel"].tap()
                XCTAssertTrue(app.buttons["resume"].exists); XCTAssertFalse(app.otherElements["arena-running"].exists)
            }
            app.buttons["restart"].tap()
            app.buttons["confirm-accept"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            pauseByTouch(app); XCTAssertTrue(app.buttons["posture-normal"].isSelected)
            app.buttons["main-menu"].tap()
            app.buttons["confirm-accept"].tap()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.buttons["mode-classic"].exists)
            app.terminate()
        }
    }

    func testRestartAfterDeathIsImmediateInBothThemes() {
        let app = XCUIApplication()
        for theme in ["ink", "classic"] {
            app.launchArguments = ["--ui-testing", "--theme-\(theme)-qa", "--gameover-qa"]
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.buttons["replay"].waitForExistence(timeout: 5))
            app.buttons["replay"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            XCTAssertFalse(app.buttons["confirm-cancel"].exists)
            XCTAssertFalse(app.alerts.firstMatch.exists)
            app.terminate()
        }
    }

    func testHardModeSelectionPersistsAndOpeningIsCrowded() {
        let app = XCUIApplication()
        for language in ["en", "es"] {
            app.launchArguments = ["--ui-testing", "--theme-ink-qa", "--hard-opening-qa", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "es" ? "es_ES" : "en_US"]
            app.launch()
            XCTAssertTrue(app.buttons["mode-hard"].waitForExistence(timeout: 10))
            app.buttons["mode-hard"].tap(); XCTAssertTrue(app.buttons["mode-hard"].isSelected)
            app.buttons["posture-normal"].tap(); capture("29-hard-menu-\(language)", app: app)
            app.buttons["play"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            capture("30-hard-opening-\(language)", app: app)
            pauseByTouch(app); XCTAssertFalse(app.buttons["mode-classic"].exists)
            app.terminate(); app.launch()
            XCTAssertTrue(app.buttons["mode-hard"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.buttons["mode-hard"].isSelected)
            app.buttons["mode-classic"].tap(); XCTAssertTrue(app.buttons["mode-classic"].isSelected)
            app.terminate()
        }
    }

    func testInkAndOriginalCanSwitchDuringPauseAndPersist() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--theme-ink-qa", "--visual-qa"]
        app.launch()
        XCTAssertTrue(app.buttons["theme-inkTide"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["theme-inkTide"].isSelected)
        capture("20-ink-menu", app: app)
        app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
        capture("21-ink-arena", app: app)
        pauseByTouch(app); app.buttons["theme-classic"].tap()
        XCTAssertTrue(app.buttons["theme-classic"].isSelected)
        app.buttons["resume"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
        capture("22-original-preserved", app: app)
        app.terminate(); app.launchArguments = ["--ui-testing"]; app.launch()
        XCTAssertTrue(app.buttons["theme-classic"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["theme-classic"].isSelected)
        app.buttons["theme-inkTide"].tap()
        app.terminate(); app.launch()
        XCTAssertTrue(app.buttons["theme-inkTide"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["theme-inkTide"].isSelected)
    }
    func testExplosionHotCoreAndDissipation() {
        let app = XCUIApplication()
        for tail in [false, true] {
            app.launchArguments = ["--ui-testing", "--explosion-vfx-qa"] + (tail ? ["--explosion-tail-qa"] : [])
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            capture(tail ? "17-explosion-dissipation" : "16-explosion-hot-core", app: app)
            app.terminate()
        }
    }
    func testBoomerangChargeBounceRecatchAndElectricRange() {
        let app = XCUIApplication()
        for (name, flags) in [
            ("18-boomerang-charging", ["--boomerang-charge-qa"]),
            ("13-boomerang-outbound", [String]()),
            ("14-boomerang-wall-bounce", ["--bouncing-qa"]),
            ("19-boomerang-recharged", ["--recaught-qa"]),
            ("15-electricity-range", ["--electricity-qa"])
        ] {
            app.launchArguments = ["--ui-testing", "--new-powers-qa"] + flags
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            Thread.sleep(forTimeInterval: 0.3)
            capture(name, app: app); app.terminate()
        }
    }
    func testSpikesOverGreenShieldAndExpiryWarning() {
        let app = XCUIApplication()
        for warning in [false, true] {
            app.launchArguments = ["--ui-testing", "--spikes-vfx-qa"] + (warning ? ["--spikes-warning-qa"] : [])
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            capture(warning ? "12-spikes-expiry-warning" : "11-spikes-over-shield", app: app)
            app.terminate()
        }
    }
    func testWaveTipChargeAndFireSteering() {
        let app = XCUIApplication()
        for (name, flags) in [
            ("08-wave-tip-charge", ["--wave-vfx-qa", "--charge-vfx-qa"]),
            ("09-wave-released", ["--wave-vfx-qa"]),
            ("10-fire-steering", ["--turn-fire-qa"])
        ] {
            app.launchArguments = ["--ui-testing", "--selected-vfx-qa"] + flags
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            capture(name, app: app); app.terminate()
        }
    }
    func testSelectedVFXChargeAndLaunch() {
        let app = XCUIApplication()
        for charging in [true, false] {
            app.launchArguments = ["--ui-testing", "--selected-vfx-qa"] + (charging ? ["--charge-vfx-qa"] : [])
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            capture(charging ? "06-selected-vfx-charge" : "07-selected-vfx-fire-trail", app: app)
            app.terminate()
        }
    }
    func testDefaultCalibrationAndSavedResume() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--fresh-controls-qa", "--theme-classic-qa"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["posture-custom"].isSelected)
        XCTAssert(["Calibrate & play", "Calibrar y jugar"].contains(app.buttons["play"].label))
        capture("00-default-calibration", app: app)
        app.buttons["play"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
        pauseByTouch(app); app.buttons["resume"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Tu postura"].exists)
        app.terminate(); app.launchArguments = ["--ui-testing"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        XCTAssert(["Play", "Jugar"].contains(app.buttons["play"].label))
        XCTAssertTrue(app.buttons["posture-custom"].isSelected)
    }
    func testNativeIceAndBlastAtPeak() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--visual-qa", "--freeze-vfx-qa"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
        // The debug fixture holds effects at their peak after 0.22 seconds.
        Thread.sleep(forTimeInterval: 0.5)
        capture("05-native-ice-and-blast", app: app)
    }
    func testLingeringAreasAndColoredOrbsInBothThemes() {
        let app = XCUIApplication()
        for theme in ["ink", "classic"] {
            app.launchArguments = ["--ui-testing", "--lingering-areas-qa", "--theme-\(theme)-qa"]
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.otherElements["temporary-theme-control"].exists)
            capture(theme == "ink" ? "27-small-theme-menu" : "28-small-theme-original-menu", app: app)
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
            capture(theme == "ink" ? "25-lingering-ink" : "26-lingering-original", app: app)
            app.terminate()
        }
    }
    private func pauseByTouch(_ app: XCUIApplication) {
        app.otherElements["arena-running"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(app.buttons["resume"].waitForExistence(timeout: 5))
    }
    func testTouchAnywherePausesAndResumeDoesNotReopenMenu() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--visual-qa"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
        for point in [CGVector(dx: 0.5, dy: 0.5), CGVector(dx: 0.08, dy: 0.12),
                      CGVector(dx: 0.92, dy: 0.12), CGVector(dx: 0.08, dy: 0.88), CGVector(dx: 0.92, dy: 0.88)] {
            let arena = app.otherElements["arena-running"]
            XCTAssertTrue(arena.waitForExistence(timeout: 5))
            XCTAssertFalse(app.buttons["pause"].exists)
            arena.coordinate(withNormalizedOffset: point).tap()
            XCTAssertTrue(app.buttons["resume"].waitForExistence(timeout: 5))
            XCTAssertFalse(arena.exists)
            app.buttons["resume"].tap()
            XCTAssertTrue(arena.waitForExistence(timeout: 5))
            XCTAssertFalse(app.buttons["resume"].exists)
        }
        capture("23-touch-pause-button-free", app: app)
        let arena = app.otherElements["arena-running"]
        arena.coordinate(withNormalizedOffset: CGVector(dx: 0.4, dy: 0.5))
            .press(forDuration: 0.1, thenDragTo: arena.coordinate(withNormalizedOffset: CGVector(dx: 0.6, dy: 0.5)))
        XCTAssertTrue(arena.exists, "Simulator movement drags must not open the pause menu")
        pauseByTouch(app)
        capture("24-touch-pause-menu", app: app)
    }
    private func capture(_ name: String, app: XCUIApplication) {
        // Capture the display: app-window screenshots crop landscape on this simulator.
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    func testPosturesPlayPauseAndResumeWithoutCalibration() {
        let app = XCUIApplication(); app.launchArguments = ["--ui-testing"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        app.buttons["posture-inclined"].tap()
        XCTAssertTrue(app.buttons["posture-inclined"].isSelected)
        capture("01-menu-wide", app: app)
        app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
        pauseByTouch(app)
        XCTAssertTrue(app.buttons["resume"].waitForExistence(timeout: 5))
        capture("02-pause", app: app)
        app.buttons["resume"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Your posture"].exists || app.staticTexts["Tu postura"].exists)
        pauseByTouch(app)
        let recalibrate = app.buttons["Recalibrate"].exists ? app.buttons["Recalibrate"] : app.buttons["Recalibrar"]
        recalibrate.tap()
        // Simulator calibration completes automatically. The saved profile is reusable.
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
        pauseByTouch(app)
        XCTAssertTrue(app.buttons["posture-custom"].isSelected)
        capture("03-custom-saved", app: app)
    }
    func testNativeGeneratedOrbsAndEffectsFixture() {
        let app = XCUIApplication(); app.launchArguments = ["--ui-testing", "--visual-qa"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
        XCTAssertTrue(app.otherElements["arena-running"].waitForExistence(timeout: 5))
        capture("04-native-art-and-vfx-fixture", app: app)
    }
}
