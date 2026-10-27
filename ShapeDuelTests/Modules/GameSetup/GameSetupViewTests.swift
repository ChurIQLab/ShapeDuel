//
//  GameSetupViewTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 28.10.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct GameSetupViewTests {

    @Test func figuresOfEachPlayerAreGroupedUnderPlayerName() {
        let view = GameSetupView()

        view.showPlayers(Side.allCases.map(player), hint: "Hint")

        let pickers = allSubviews(of: view).compactMap { $0 as? FigurePickerView }
        #expect(pickers.map(\.accessibilityLabel) == Side.allCases.map {
            String(localized: .playerFigures($0.defaultPlayerName))
        })
        #expect(pickers.allSatisfy { $0.accessibilityContainerType == .semanticGroup })
    }
}

extension GameSetupViewTests {

    // MARK: - Private methods

    private func player(_ side: Side) -> PlayerSetupViewModel {
        PlayerSetupViewModel(
            nameField: NameFieldViewModel(
                side: side,
                label: side.defaultPlayerName,
                placeholder: side.defaultPlayerName,
                text: "",
                maxLength: GameConfiguration.maxNameLength
            ),
            figurePicker: FigurePickerViewModel(side: side, selected: Figure.defaultFigure(for: side), taken: nil)
        )
    }

    private func allSubviews(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + allSubviews(of: $0) }
    }
}
