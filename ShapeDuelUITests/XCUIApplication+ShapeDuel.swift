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

// MARK: - Constants

extension XCUIApplication {
    struct Constants {
        /// Long enough for a transition on a slow CI runner
        static let timeout: TimeInterval = 10
        /// Keys of `SettingsService`
        static let defaultChoices = [
            "twoPlayers.firstFigure": "cross",
            "twoPlayers.secondFigure": "circle",
            "twoPlayers.firstName": "",
            "twoPlayers.secondName": "",
            "computer.playerFigure": "cross"
        ]
    }
}
