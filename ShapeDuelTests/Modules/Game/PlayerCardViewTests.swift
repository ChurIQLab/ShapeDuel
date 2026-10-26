//
//  PlayerCardViewTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 26.10.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct PlayerCardViewTests {

    @Test func cardIsNamedAfterPlayerAndFigure() {
        let card = PlayerCardView()

        card.configure(with: player(state: .inactive, score: 0))

        #expect(card.isAccessibilityElement)
        #expect(card.accessibilityLabel == "Anna, \(Figure.star.accessibilityName)")
        #expect(card.accessibilityTraits == .none)
    }

    @Test(arguments: [
        (PlayerCardViewModel.State.active, String(localized: .movingPlayer) + ", "),
        (.winner, String(localized: .winnerPlayer) + ", "),
        (.inactive, ""),
        (.neutral, "")
    ])
    func valueTellsStateBeforeScore(state: PlayerCardViewModel.State, prefix: String) {
        let card = PlayerCardView()

        card.configure(with: player(state: state, score: 2))

        #expect(card.accessibilityValue == prefix + String(localized: .playerScore(2)))
    }
}

extension PlayerCardViewTests {

    // MARK: - Private methods

    private func player(state: PlayerCardViewModel.State, score: Int) -> PlayerCardViewModel {
        PlayerCardViewModel(side: .first, figure: .star, name: "Anna", score: score, state: state)
    }
}
