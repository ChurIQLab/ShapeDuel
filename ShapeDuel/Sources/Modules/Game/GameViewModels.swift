//
//  GameViewModels.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 23.09.2026.
//

import Foundation

nonisolated struct PlayerCardViewModel: Equatable, Sendable {
    let side: Side
    let figure: Figure
    let name: String
    let score: Int
    let state: State
}

// MARK: - State

extension PlayerCardViewModel {
    nonisolated enum State: Equatable, Sendable {
        /// Moves now
        case active
        /// Has just won; highlighted like `active`
        case winner
        case inactive
        /// Nobody is highlighted after a draw
        case neutral
    }
}

// MARK: - GameStatusViewModel

nonisolated struct GameStatusViewModel: Equatable, Sendable {
    let text: String
    /// The player named in `text`: the name is highlighted and preceded by the figure
    let player: Player?
}

extension GameStatusViewModel {
    nonisolated struct Player: Equatable, Sendable {
        let side: Side
        let figure: Figure
        let name: String
        /// Where the name is in `text`: a name may repeat a word of the phrase, so it is not searched for
        let nameRange: NSRange
    }
}

// MARK: - Initial

extension GameStatusViewModel {
    /// Puts the player's name into a localized phrase, such as `{ String(localized: .turnStatus($0)) }`,
    /// and keeps the place where the phrase put it
    init(side: Side, figure: Figure, name: String, phrase: (String) -> String) {
        let template = phrase(Constants.namePlaceholder) as NSString
        let placeholderRange = template.range(of: Constants.namePlaceholder)
        guard placeholderRange.location != NSNotFound else {
            self.init(text: phrase(name), player: nil)
            return
        }

        let text = template.replacingCharacters(in: placeholderRange, with: name)
        let nameRange = NSRange(location: placeholderRange.location, length: (name as NSString).length)
        self.init(
            text: text,
            player: Player(side: side, figure: figure, name: name, nameRange: nameRange)
        )
    }
}

// MARK: - Constants

extension GameStatusViewModel {
    nonisolated struct Constants {
        /// A private use character: it is not typed in names and not used in translations
        static let namePlaceholder = "\u{E000}"
    }
}

// MARK: - WinningLineViewModel

nonisolated struct WinningLineViewModel: Equatable, Sendable {
    let side: Side
    let start: Position
    let end: Position
}

// MARK: - GameResultViewModel

nonisolated struct GameResultViewModel: Equatable, Sendable {
    let title: String
    let score: String
    /// The winner's figure, or the figures of both sides after a draw
    let figures: [SideFigure]
    /// Tints the badge; `nil` after a draw
    let winner: Side?
}

// MARK: - SideFigure

nonisolated struct SideFigure: Equatable, Sendable {
    let side: Side
    let figure: Figure
}
