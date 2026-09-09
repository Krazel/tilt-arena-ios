import XCTest

final class ClassicFlowTests: XCTestCase {
    func testExplosionHotCoreAndDissipation() {
        let app = XCUIApplication()
        for tail in [false, true] {
            app.launchArguments = ["--ui-testing", "--explosion-vfx-qa"] + (tail ? ["--explosion-tail-qa"] : [])
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
            capture(tail ? "17-explosion-dissipation" : "16-explosion-hot-core", app: app)
            app.terminate()
        }
    }
    func testNewPowersOutboundReturnAndElectricRange() {
        let app = XCUIApplication()
        for (name, flags) in [
            ("13-boomerang-outbound", [String]()),
            ("14-boomerang-return", ["--returning-qa"]),
            ("15-electricity-range", ["--electricity-qa"])
        ] {
            app.launchArguments = ["--ui-testing", "--new-powers-qa"] + flags
            app.launch()
            XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
            app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
            XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
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
            XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
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
            XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
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
            XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
            capture(charging ? "06-selected-vfx-charge" : "07-selected-vfx-fire-trail", app: app)
            app.terminate()
        }
    }
    func testDefaultCalibrationAndSavedResume() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--fresh-controls-qa"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["posture-custom"].isSelected)
        XCTAssertEqual(app.buttons["play"].label, "Calibrar y jugar")
        capture("00-default-calibration", app: app)
        app.buttons["play"].tap()
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
        app.buttons["pause"].tap(); app.buttons["resume"].tap()
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Tu postura"].exists)
        app.terminate(); app.launchArguments = ["--ui-testing"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons["play"].label, "Jugar")
        XCTAssertTrue(app.buttons["posture-custom"].isSelected)
    }
    func testNativeIceAndBlastAtPeak() {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--visual-qa", "--freeze-vfx-qa"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
        // The debug fixture holds effects at their peak after 0.22 seconds.
        Thread.sleep(forTimeInterval: 0.5)
        capture("05-native-ice-and-blast", app: app)
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
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
        app.buttons["pause"].tap()
        XCTAssertTrue(app.buttons["resume"].waitForExistence(timeout: 5))
        capture("02-pause", app: app)
        app.buttons["resume"].tap()
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Tu postura"].exists)
        app.buttons["pause"].tap(); app.buttons["Recalibrar"].tap()
        // Simulator calibration completes automatically. The saved profile is reusable.
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
        app.buttons["pause"].tap()
        XCTAssertTrue(app.buttons["posture-custom"].isSelected)
        capture("03-custom-saved", app: app)
    }
    func testNativeGeneratedOrbsAndEffectsFixture() {
        let app = XCUIApplication(); app.launchArguments = ["--ui-testing", "--visual-qa"]; app.launch()
        XCTAssertTrue(app.buttons["play"].waitForExistence(timeout: 10))
        app.buttons["posture-normal"].tap(); app.buttons["play"].tap()
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout: 5))
        capture("04-native-art-and-vfx-fixture", app: app)
    }
}
