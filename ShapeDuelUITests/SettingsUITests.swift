//
//  SettingsUITests.swift
//  ShapeDuelUITests
//
//  Created by Churkin Vitaly on 10.11.2026.
//

import XCTest

final class SettingsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testThemeIsKeptAfterRelaunch() {
        let app = XCUIApplication.launchedShapeDuel()
        // The theme is saved on the simulator, so the test returns the default one
        addTeardownBlock { @MainActor in
            app.launch()
            app.tapButton("Settings")
            app.tapButton("System")
        }

        app.tapButton("Settings")
        app.tapButton("Dark")
        XCTAssertTrue(app.buttons["Dark"].isSelected)

        app.terminate()
        app.launch()
        app.tapButton("Settings")

        XCTAssertTrue(app.buttons["Dark"].waitForExistence(timeout: XCUIApplication.Constants.timeout))
        XCTAssertTrue(app.buttons["Dark"].isSelected)
        XCTAssertFalse(app.buttons["System"].isSelected)
    }
}
