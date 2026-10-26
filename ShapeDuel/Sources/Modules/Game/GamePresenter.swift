//
//  GamePresenter.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 06.10.2024.
//

import Foundation

final class GamePresenter {

    // MARK: - Properties

    weak var view: GameViewProtocol?
    private let configuration: GameConfiguration
    private let router: GameRouting
    private let haptics: HapticsServiceProtocol
    private let scheduler: ComputerMoveScheduling
    private var engine = GameEngine()
    /// Alternates after every finished game; a restarted game keeps its first side
    private var firstSide: Side = .first
    private var scores: [Side: Int] = [:]

    /// The computer plays the second side; `nil` in the two-player mode
    private var computerSide: Side? {
        switch configuration.mode {
        case .computer: .second
        case .twoPlayers: nil
        }
    }

    /// While it is on, taps on the board are ignored
    private var isComputerTurn: Bool {
        engine.result == nil && engine.currentSide == computerSide
    }

    // MARK: - Initial

    init(
        configuration: GameConfiguration,
        router: GameRouting,
        haptics: HapticsServiceProtocol,
        scheduler: ComputerMoveScheduling
    ) {
        self.configuration = configuration
        self.router = router
        self.haptics = haptics
        self.scheduler = scheduler
    }

    // MARK: - Private methods

    private func startNewGame() {
        scheduler.cancel()
        engine = GameEngine(firstSide: firstSide)
        view?.resetBoard()
        updatePanels()
        scheduleComputerMoveIfNeeded()
    }

    /// Shared by the player's taps and the computer's moves
    private func play(at position: Position) {
        let side = engine.currentSide

        do {
            try engine.play(at: position)
        } catch {
            return
        }

        view?.showFigure(figure(for: side), for: side, at: position)

        guard let result = engine.result else {
            if side != computerSide {
                haptics.playMove()
            }
            updatePanels()
            scheduleComputerMoveIfNeeded()
            return
        }
        finishGame(with: result)
        updatePanels()
        view?.showGameOver(resultViewModel(for: result), winningLine: winningLine(for: result))
    }

    private func scheduleComputerMoveIfNeeded() {
        guard isComputerTurn else { return }
        scheduler.scheduleMove(
            on: engine.board,
            as: engine.currentSide,
            by: configuration.difficulty.computerPlayer
        ) { [weak self] position in
            guard let self, let position, isComputerTurn else { return }
            play(at: position)
        }
    }

    private func finishGame(with result: GameResult) {
        switch result {
        case .win(let side, _):
            scores[side, default: 0] += 1
            if side == computerSide {
                haptics.playLoss()
            } else {
                haptics.playWin()
            }
        case .draw:
            haptics.playDraw()
        }
        firstSide = firstSide.opponent
    }

    private func updatePanels() {
        updatePlayers()
        updateStatus()
        view?.setBoardLocked(isComputerTurn)
    }

    private func updatePlayers() {
        let players = Side.allCases.map { side in
            PlayerCardViewModel(
                side: side,
                figure: figure(for: side),
                name: name(for: side),
                score: scores[side, default: 0],
                state: cardState(for: side)
            )
        }
        view?.updatePlayers(players)
    }

    private func updateStatus() {
        let status = switch engine.result {
        case .draw:
            GameStatusViewModel(text: String(localized: .drawMessage), player: nil)
        case .win(let winner, _):
            winStatus(of: winner)
        case nil:
            turnStatus(of: engine.currentSide)
        }
        view?.updateStatus(status)
    }

    private func turnStatus(of side: Side) -> GameStatusViewModel {
        switch configuration.mode {
        case .twoPlayers:
            return status(naming: side) { String(localized: .turnStatus($0)) }
        case .computer:
            guard side == computerSide else {
                // «Your turn» has no name to put in, so the whole phrase is highlighted
                return GameStatusViewModel(
                    side: side,
                    figure: figure(for: side),
                    name: String(localized: .yourTurnStatus)
                ) { $0 }
            }
            return status(naming: side) { String(localized: .computerThinkingStatus($0)) }
        }
    }

    private func winStatus(of side: Side) -> GameStatusViewModel {
        switch configuration.mode {
        case .twoPlayers:
            status(naming: side) { String(localized: .winStatus($0)) }
        case .computer where side == computerSide:
            status(naming: side) { String(localized: .computerWinStatus($0)) }
        case .computer:
            status(naming: side) { String(localized: .youWinStatus($0)) }
        }
    }

    private func status(naming side: Side, phrase: (String) -> String) -> GameStatusViewModel {
        GameStatusViewModel(side: side, figure: figure(for: side), name: name(for: side), phrase: phrase)
    }

    private func cardState(for side: Side) -> PlayerCardViewModel.State {
        switch engine.result {
        case .draw: .neutral
        case .win(let winner, _): winner == side ? .winner : .inactive
        case nil: engine.currentSide == side ? .active : .inactive
        }
    }

    private func figure(for side: Side) -> Figure {
        configuration.figures[side] ?? Figure.defaultFigure(for: side)
    }

    private func name(for side: Side) -> String {
        switch configuration.mode {
        case .twoPlayers:
            configuration.names[side] ?? side.defaultPlayerName
        case .computer:
            if side == computerSide { String(localized: .computerName) } else { String(localized: .youName) }
        }
    }

    private func winnerTitle(for side: Side) -> String {
        switch configuration.mode {
        case .twoPlayers:
            String(localized: .winnerTitle(name(for: side)))
        case .computer:
            if side == computerSide { String(localized: .computerWinTitle) } else { String(localized: .youWinTitle) }
        }
    }

    private func winningLine(for result: GameResult) -> WinningLineViewModel? {
        guard
            case .win(let side, let line) = result,
            let start = line.first,
            let end = line.last
        else { return nil }
        return WinningLineViewModel(side: side, start: start, end: end)
    }

    private func resultViewModel(for result: GameResult) -> GameResultViewModel {
        let score = String(localized: .scoreSubtitle(scores[.first, default: 0], scores[.second, default: 0]))
        switch result {
        case .win(let side, _):
            return GameResultViewModel(
                title: winnerTitle(for: side),
                score: score,
                figures: [SideFigure(side: side, figure: figure(for: side))],
                winner: side
            )
        case .draw:
            return GameResultViewModel(
                title: String(localized: .drawMessage),
                score: score,
                figures: Side.allCases.map { SideFigure(side: $0, figure: figure(for: $0)) },
                winner: nil
            )
        }
    }
}

// MARK: - GamePresenterProtocol

extension GamePresenter: GamePresenterProtocol {
    func viewDidLoad() {
        view?.setTitle(configuration.mode.title)
        startNewGame()
    }

    func didTapCell(at position: Position) {
        guard !isComputerTurn else { return }
        play(at: position)
    }

    func didTapNewGame() {
        startNewGame()
    }

    func didTapMenu() {
        scheduler.cancel()
        router.showMenu()
    }
}
