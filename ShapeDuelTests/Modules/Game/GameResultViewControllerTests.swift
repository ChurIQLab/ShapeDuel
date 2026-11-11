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

    @Test func titleAndScoreAreOneHeaderElement() throws {
        let result = GameResultViewModel(
            title: "Anna wins",
            score: "Score 1 : 0",
            figures: [SideFigure(side: .first, figure: .cross)],
            winner: .first
        )
        let viewController = GameResultViewController(result: result, onPlayAgain: {}, onMenu: {})

        viewController.loadViewIfNeeded()

        let elements = allSubviews(of: viewController.view).filter(\.isAccessibilityElement)
        let header = try #require(elements.first { $0.accessibilityTraits.contains(.header) })
        #expect(header.accessibilityLabel == "Anna wins, Score 1 : 0")
        #expect(header.subviews.contains { ($0 as? UILabel)?.text == result.title })
        #expect(header.subviews.contains { ($0 as? UILabel)?.text == result.score })
    }
}

extension GameResultViewControllerTests {

    // MARK: - Private methods

    private func allSubviews(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + allSubviews(of: $0) }
    }
}
