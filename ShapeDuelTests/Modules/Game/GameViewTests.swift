//
//  GameViewTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 22.10.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct GameViewTests {

    @Test func freeCellIsButtonNamedAfterItsPlace() throws {
        let view = GameView()
        let position = try #require(Position(row: 0, column: 2))

        let cell = try #require(boardCell(at: position, in: view))

        #expect(cell.accessibilityValue == String(localized: .emptyCell))
        #expect(cell.accessibilityTraits == .button)
    }

    @Test func occupiedCellTellsFigureAndOwner() throws {
        let view = GameView()
        let position = try #require(Position(row: 1, column: 1))
        view.updatePlayers([player(.first, name: "Anna")])

        view.showFigure(.star, for: .first, at: position)

        let cell = try #require(boardCell(at: position, in: view))
        #expect(cell.accessibilityValue == "\(Figure.star.accessibilityName), Anna")
        #expect(cell.accessibilityTraits == .none)
    }

    @Test func lockedFreeCellIsNotEnabled() throws {
        let view = GameView()
        let position = try #require(Position(row: 2, column: 0))

        view.setBoardLocked(true)

        let cell = try #require(boardCell(at: position, in: view))
        #expect(cell.accessibilityTraits == [.button, .notEnabled])
    }

    @Test func resetCellIsFreeAgain() throws {
        let view = GameView()
        let position = try #require(Position(row: 0, column: 0))
        view.showFigure(.cross, for: .first, at: position)

        view.reset()

        let cell = try #require(boardCell(at: position, in: view))
        #expect(cell.accessibilityValue == String(localized: .emptyCell))
        #expect(cell.accessibilityTraits == .button)
    }
}

extension GameViewTests {

    // MARK: - Private methods

    private func boardCell(at position: Position, in view: UIView) -> UIView? {
        let name = position.accessibilityName
        return allSubviews(of: view).first { $0 is UIControl && $0.accessibilityLabel == name }
    }

    private func allSubviews(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + allSubviews(of: $0) }
    }

    private func player(_ side: Side, name: String) -> PlayerCardViewModel {
        PlayerCardViewModel(side: side, figure: .star, name: name, score: 0, state: .active)
    }
}
