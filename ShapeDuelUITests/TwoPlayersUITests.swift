//
//  TwoPlayersUITests.swift
//  ShapeDuelUITests
//
//  Created by Churkin Vitaly on 01.11.2026.
//

import XCTest

final class TwoPlayersUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testGameToWinAndNextGame() {
        let app = XCUIApplication.launchedShapeDuel()

        app.tapButton("Two players")
        app.tapButton("Play")
        app.assertShows("Player 1's turn")

        // The first player completes the top row
        for cell in ["Top left", "Middle left", "Top center", "Center", "Top right"] {
            app.tapButton(cell)
        }
        app.assertShows("Player 1 wins, Score 1 : 0")

        // The next game starts with the other player
        app.tapButton("Play again")
        app.assertShows("Player 2's turn")
        app.assertShows("Top left")
    }
}
