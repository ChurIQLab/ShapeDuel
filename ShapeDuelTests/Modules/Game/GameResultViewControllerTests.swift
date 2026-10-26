//
//  GameResultViewControllerTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 26.10.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct GameResultViewControllerTests {

    @Test func titleIsReadWithScoreAndScoreIsNotReadTwice() throws {
        let result = GameResultViewModel(
            title: "Anna wins",
            score: "Score 1 : 0",
            figures: [SideFigure(side: .first, figure: .cross)],
            winner: .first
        )
        let viewController = GameResultViewController(result: result, onPlayAgain: {}, onMenu: {})

        viewController.loadViewIfNeeded()

        let labels = allSubviews(of: viewController.view).compactMap { $0 as? UILabel }
        let title = try #require(labels.first { $0.text == result.title })
        let score = try #require(labels.first { $0.text == result.score })
        #expect(title.accessibilityLabel == "Anna wins, Score 1 : 0")
        #expect(title.accessibilityTraits.contains(.header))
        #expect(!score.isAccessibilityElement)
    }
}

extension GameResultViewControllerTests {

    // MARK: - Private methods

    private func allSubviews(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + allSubviews(of: $0) }
    }
}
