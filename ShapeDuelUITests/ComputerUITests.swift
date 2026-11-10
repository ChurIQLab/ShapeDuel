//
//  ComputerUITests.swift
//  ShapeDuelUITests
//
//  Created by Churkin Vitaly on 10.11.2026.
//

import XCTest

final class ComputerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// The computer's moves are random, so the player takes the first free cell until the game ends
    /// with any result
    @MainActor
    func testGameToEndAndBackToMenu() throws {
        let app = XCUIApplication.launchedShapeDuel()
        app.tapButton("Against the computer")
        app.tapButton("Play")

        let playAgainButton = app.buttons["Play again"]
        let yourTurn = app.descendants(matching: .any)["Your turn"]
        for _ in 0..<Constants.maxPlayerMoves {
            // The turn comes back after the computer's pause, the sheet after the line of the last move
            let isPlayerTurn = yourTurn.waitForExistence(timeout: XCUIApplication.Constants.timeout)
            if playAgainButton.exists { break }
            XCTAssertTrue(isPlayerTurn, "The player's turn does not come")
            let cell = try XCTUnwrap(freeCell(in: app), "No free cell on the player's turn")
            cell.tap()
            if playAgainButton.waitForExistence(timeout: Constants.sheetCheckTimeout) { break }
        }

        XCTAssertTrue(playAgainButton.waitForExistence(timeout: XCUIApplication.Constants.timeout))
        let resultTitle = app.staticTexts.matching(
            NSPredicate(format: "label BEGINSWITH 'You win' OR label BEGINSWITH 'Computer wins' "
                + "OR label BEGINSWITH \"It's a draw\"")
        )
        XCTAssertEqual(resultTitle.count, 1)

        app.tapButton("Menu")
        app.assertShows("Two players")
    }
}

// MARK: - Private methods

extension ComputerUITests {
    /// A free cell is a button; while the computer moves it is not enabled
    @MainActor
    private func freeCell(in app: XCUIApplication) -> XCUIElement? {
        Constants.cells.lazy
            .map { app.buttons[$0] }
            .first { $0.exists && $0.isEnabled }
    }
}

// MARK: - Constants

extension ComputerUITests {
    struct Constants {
        static let cells = [
            "Top left", "Top center", "Top right",
            "Middle left", "Center", "Middle right",
            "Bottom left", "Bottom center", "Bottom right"
        ]
        /// The player starts and makes at most five moves on a 3×3 board
        static let maxPlayerMoves = 5
        /// After the player's move: the sheet only shows up if the move ended the game
        static let sheetCheckTimeout: TimeInterval = 2
    }
}
