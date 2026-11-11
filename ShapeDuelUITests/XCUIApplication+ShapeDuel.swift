//
//  XCUIApplication+ShapeDuel.swift
//  ShapeDuelUITests
//
//  Created by Churkin Vitaly on 01.11.2026.
//

import XCTest

extension XCUIApplication {

    // MARK: - Methods

    /// Elements are found by their VoiceOver labels, so the language is fixed.
    /// Arguments win over the values saved on the simulator: a test starts from the default choices
    @MainActor
    static func launchedShapeDuel() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchArguments += Constants.defaultChoices.flatMap { ["-\($0.key)", $0.value] }
        app.launch()
        return app
    }

    @MainActor
    func tapButton(
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let button = buttons[label]
        XCTAssertTrue(
            button.waitForExistence(timeout: Constants.timeout),
            "No button «\(label)»",
            file: file,
            line: line
        )
        button.tap()
    }

    /// Any element with this VoiceOver label: the status line is not a static text
    @MainActor
    func assertShows(
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            descendants(matching: .any)[label].waitForExistence(timeout: Constants.timeout),
            "Nothing shows «\(label)»",
            file: file,
            line: line
        )
    }
}

// MARK: - Transitions

extension XCUIApplication {
    /// Waits for a transition to end: the element of the screen left behind is gone or hidden by a sheet.
    /// On a slow CI runner an audit run during a transition reports the leaving screen
    @MainActor
    func assertGone(
        _ label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            descendants(matching: .any)[label].waitForNonExistence(timeout: Constants.timeout),
            "«\(label)» is still shown",
            file: file,
            line: line
        )
    }

    /// Waits for an element of a presented sheet to stop moving
    @MainActor
    func assertSettled(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(element.waitForExistence(timeout: Constants.timeout), file: file, line: line)
        var frame = element.frame
        let deadline = Date().addingTimeInterval(Constants.timeout)
        while Date() < deadline {
            Thread.sleep(forTimeInterval: Constants.settleCheckInterval)
            if element.frame == frame { return }
            frame = element.frame
        }
        XCTFail("«\(element.label)» keeps moving", file: file, line: line)
    }
}

// MARK: - Constants

extension XCUIApplication {
    struct Constants {
        /// Long enough for a transition on a slow CI runner
        static let timeout: TimeInterval = 10
        static let settleCheckInterval: TimeInterval = 0.5
        /// Keys of `SettingsService`
        static let defaultChoices = [
            "twoPlayers.firstFigure": "cross",
            "twoPlayers.secondFigure": "circle",
            "twoPlayers.firstName": "",
            "twoPlayers.secondName": "",
            "computer.playerFigure": "cross",
            "computer.difficulty": "medium"
        ]
    }
}
