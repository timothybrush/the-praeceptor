import XCTest

/// Screenshot capture flow — full first-run user journey.
/// Requires /tmp/praeceptor_keys.plist with at least a "claude" key.
@MainActor
final class ScreenshotFlow: XCTestCase {

    private let app = XCUIApplication()
    private let outputDir = "/tmp/praeceptor-screenshots/flow"

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            atPath: outputDir, withIntermediateDirectories: true, attributes: nil
        )
        app.launchArguments += ["--skip-splash", "--fresh-start"]
        app.launch()
    }

    func testCaptureFlow() throws {
        let keys = try loadKeys()
        guard let claudeKey = keys["claude"], !claudeKey.isEmpty else {
            XCTFail("claude key required in /tmp/praeceptor_keys.plist")
            return
        }

        // ── Settings root ──────────────────────────────────────────────────────
        // --skip-splash skips the animation entirely; Settings should appear within 2s
        let apiRow = app.staticTexts["API & AUTHORIZATION"]
        XCTAssertTrue(apiRow.waitForExistence(timeout: 8), "Settings not found after launch")
        capture("01_settings_root")

        // ── Voice settings sub-screen ─────────────────────────────────────────
        app.staticTexts["VOICE"].tap()
        Thread.sleep(forTimeInterval: 0.8)
        capture("02_voice_settings")
        app.buttons["Back"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertTrue(app.staticTexts["API & AUTHORIZATION"].waitForExistence(timeout: 5))

        // ── Reminders sub-screen ───────────────────────────────────────────────
        app.staticTexts["REMINDERS"].tap()
        Thread.sleep(forTimeInterval: 0.8)
        capture("03_reminders")
        app.buttons["Back"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertTrue(app.staticTexts["API & AUTHORIZATION"].waitForExistence(timeout: 5))

        // ── API Auth — empty ───────────────────────────────────────────────────
        apiRow.tap()
        Thread.sleep(forTimeInterval: 0.5)
        capture("04_api_auth_empty")

        // ── Enter keys ────────────────────────────────────────────────────────
        let secureFields = app.secureTextFields
        XCTAssertTrue(secureFields.firstMatch.waitForExistence(timeout: 5))

        secureFields.element(boundBy: 0).tap()
        secureFields.element(boundBy: 0).typeText(claudeKey)
        if let oKey = keys["openai"], !oKey.isEmpty {
            secureFields.element(boundBy: 1).tap()
            secureFields.element(boundBy: 1).typeText(oKey)
        }
        if let eKey = keys["elevenlabs"], !eKey.isEmpty {
            secureFields.element(boundBy: 2).tap()
            secureFields.element(boundBy: 2).typeText(eKey)
        }
        Thread.sleep(forTimeInterval: 0.3)
        capture("05_api_auth_filled")

        // ── Save → intro ───────────────────────────────────────────────────────
        app.buttons["Save"].tap()
        Thread.sleep(forTimeInterval: 2.0)

        // ── Intro: definition block fades in ────────────────────────────────────
        // Animation: 0.3s pause + 0.7s fade-in + 2.7s hold + 0.6s fade-out + 0.7s = 5s to lines
        let mentorLabel = app.staticTexts["THE PRAECEPTOR"]
        XCTAssertTrue(mentorLabel.waitForExistence(timeout: 8))
        capture("06_intro_definition_block")

        // Wait for "A mentor." line (appears after definition block fades, ~5s from start)
        Thread.sleep(forTimeInterval: 4.0)
        capture("06b_intro_first_line")

        // ── Intro: all lines + Continue ─────────────────────────────────────────
        // Total animation: ~11.7s from intro start. Wait for Continue to be hittable.
        // descIntervals = [0.3, 1.0, 1.3, 1.3, 1.3] + 1.2s continueInterval = ~7.4s after lines start
        let continueBtn = app.buttons["Continue"]
        var elapsed = 0.0
        while !continueBtn.isHittable && elapsed < 22.0 {
            Thread.sleep(forTimeInterval: 0.5)
            elapsed += 0.5
        }
        XCTAssertTrue(continueBtn.isHittable, "Continue button never became hittable (intro animation timeout)")
        capture("07_intro_full_with_continue")
        continueBtn.tap()
        Thread.sleep(forTimeInterval: 1.2)

        // ── Intake Welcome ────────────────────────────────────────────────────
        capture("08_intake_welcome")
        let welcomeCont = app.buttons["Continue"]
        if welcomeCont.waitForExistence(timeout: 6) {
            welcomeCont.tap()
        }
        Thread.sleep(forTimeInterval: 1.2)
        capture("08b_after_welcome_tap")

        // ── Intake Q1 ─────────────────────────────────────────────────────────
        // TextField(axis: .vertical) may appear as textView or textField depending on iOS version
        let intakeTV = app.textViews.firstMatch
        let intakeTF = app.textFields.firstMatch
        let intakeField: XCUIElement
        if intakeTV.waitForExistence(timeout: 5) {
            intakeField = intakeTV
        } else if intakeTF.waitForExistence(timeout: 3) {
            intakeField = intakeTF
        } else {
            XCTFail("Intake Q1 not found"); return
        }
        capture("09_intake_q1_name")

        // Tap by coordinate (field is small — element.tap() doesn't always focus it)
        intakeField.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        Thread.sleep(forTimeInterval: 0.8)
        app.typeText("Ariel")
        Thread.sleep(forTimeInterval: 0.3)
        capture("09b_intake_q1_filled")

        // Continue through intake — Q2
        let cont = app.buttons["Continue"]
        if cont.waitForExistence(timeout: 4), cont.isHittable { cont.tap() }
        Thread.sleep(forTimeInterval: 0.6)
        capture("10_intake_q2_work")

        let f2tf = app.textFields.firstMatch
        let f2tv = app.textViews.firstMatch
        let f2: XCUIElement? = f2tf.waitForExistence(timeout: 3) ? f2tf : (f2tv.waitForExistence(timeout: 2) ? f2tv : nil)
        if let f2 = f2 {
            f2.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            Thread.sleep(forTimeInterval: 0.8)
            app.typeText("An iOS voice mentorship app.")
            Thread.sleep(forTimeInterval: 0.3)
        }
        if app.buttons["Continue"].waitForExistence(timeout: 3) {
            app.buttons["Continue"].tap()
        }
        Thread.sleep(forTimeInterval: 0.6)
        capture("11_intake_q3")

        // Q3–Q6: tap question text area to dismiss keyboard, then tap field to refocus
        for _ in 3...6 {
            if app.buttons["Begin"].waitForExistence(timeout: 1), app.buttons["Begin"].isHittable {
                capture("11_intake_final")
                app.buttons["Begin"].tap()
                break
            }
            // Dismiss any lingering keyboard by tapping the question text (top quarter)
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.25)).tap()
            Thread.sleep(forTimeInterval: 0.4)
            // Tap field to bring keyboard back up
            let fld = app.textFields.firstMatch
            if fld.waitForExistence(timeout: 3) {
                fld.tap()
                Thread.sleep(forTimeInterval: 0.8)
                app.typeText("x")
                Thread.sleep(forTimeInterval: 0.3)
            }
            let btn = app.buttons["Continue"]
            if btn.waitForExistence(timeout: 3), btn.isHittable { btn.tap() }
            Thread.sleep(forTimeInterval: 0.6)
        }
        if app.buttons["Begin"].waitForExistence(timeout: 5) {
            capture("11_intake_final")
            app.buttons["Begin"].tap()
        }
        Thread.sleep(forTimeInterval: 1.0)

        // ── Session (idle) ────────────────────────────────────────────────────
        let holdText = app.staticTexts["Hold to speak."]
        let holdText2 = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH 'Hold'")).firstMatch
        if holdText.waitForExistence(timeout: 8) || holdText2.waitForExistence(timeout: 2) {
            capture("12_session_empty")
        }
    }

    // MARK: — Helpers

    private func loadKeys() throws -> [String: String] {
        let url = URL(fileURLWithPath: "/tmp/praeceptor_keys.plist")
        guard let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String]
        else {
            throw XCTSkip("Write /tmp/praeceptor_keys.plist first")
        }
        return dict
    }

    private func capture(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        try? shot.pngRepresentation.write(to: URL(fileURLWithPath: "\(outputDir)/\(name).png"))
        let att = XCTAttachment(screenshot: shot)
        att.name = name
        att.lifetime = .keepAlways
        add(att)
        print("[Screenshot] saved → \(outputDir)/\(name).png")
    }
}
