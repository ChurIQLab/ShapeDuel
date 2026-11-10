//
//  AccessibilityAuditUITests.swift
//  ShapeDuelUITests
//
//  Created by Churkin Vitaly on 10.11.2026.
//

import XCTest

/// Runs the system accessibility audit on every screen: labels, contrast, hit areas, Dynamic Type
final class AccessibilityAuditUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    func testMenuAndSettings() throws {
        let app = XCUIApplication.launchedShapeDuel()
        try audit(app)

        app.tapButton("Settings")
        try audit(app, allowing: [.cappedSegmentTitles])
    }

    @MainActor
    func testTwoPlayersSetupGameAndResult() throws {
        let app = XCUIApplication.launchedShapeDuel()
        app.tapButton("Two players")
        try audit(app)

        app.tapButton("Play")
        app.tapButton("Center")
        try audit(app, allowing: [.rebuiltStatusText, .shrinkingPlayerNames])

        // The second player completes the left column
        for cell in ["Top left", "Top center", "Middle left", "Top right", "Bottom left"] {
            app.tapButton(cell)
        }
        app.assertShows("Player 2 wins, Score 0 : 1")
        try audit(app)
    }

    @MainActor
    func testComputerSetup() throws {
        let app = XCUIApplication.launchedShapeDuel()
        app.tapButton("Against the computer")
        try audit(app, allowing: [.cappedSegmentTitles])
    }
}

// MARK: - Private methods

extension AccessibilityAuditUITests {
    @MainActor
    private func audit(_ app: XCUIApplication, allowing allowedIssues: [AllowedIssue] = []) throws {
        try app.performAccessibilityAudit { issue in
            allowedIssues.contains { $0.matches(issue) }
        }
    }
}

// MARK: - AllowedIssue

extension AccessibilityAuditUITests {
    /// Deliberate choices the audit reports. It does not name the element of these issues,
    /// so they are told apart by the type and the description and allowed only on their screens
    private enum AllowedIssue {
        /// The segment titles stop growing at xxxL like in the system segmented control;
        /// a long press shows them in the Large Content Viewer
        case cappedSegmentTitles
        /// The status line is attributed text with the figure image; it is built again on a new text size,
        /// which the audit does not see (covered by `ContentSizeTests`)
        case rebuiltStatusText
        /// A player name stays on one line and shrinks before an ellipsis; on the accessibility sizes
        /// the cards go one under the other, so a usual name fits
        case shrinkingPlayerNames

        func matches(_ issue: XCUIAccessibilityAuditIssue) -> Bool {
            switch self {
            case .cappedSegmentTitles:
                issue.auditType == .dynamicType && issue.compactDescription.contains("partially")
            case .rebuiltStatusText:
                issue.auditType == .dynamicType && !issue.compactDescription.contains("partially")
            case .shrinkingPlayerNames:
                issue.auditType == .textClipped
            }
        }
    }
}
