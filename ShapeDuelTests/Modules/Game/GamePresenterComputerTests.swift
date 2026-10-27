//
//  GamePresenterComputerTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 03.10.2026.
//

import Testing
@testable import ShapeDuel

/// The game against the computer: the player is the first side, the computer the second
struct GamePresenterComputerTests {

    @Test func cardsNamePlayerAndComputer() {
        let game = makeGame()

        #expect(game.view.players.map(\.name) == [String(localized: .youName), String(localized: .computerName)])
    }

    @Test func playerStartsFirstGameWithUnlockedBoard() {
        let game = makeGame()

        #expect(game.scheduler.scheduledSides.isEmpty)
        #expect(game.view.isBoardLocked == false)
        #expect(game.view.status == GameStatusViewModel(
            side: .first,
            figure: .cross,
            name: String(localized: .yourTurnStatus)
        ) { $0 })
    }

    @Test func playerMoveLocksBoardWhileComputerThinks() throws {
        let game = makeGame()

        game.presenter.didTapCell(at: try .at(1, 1))

        #expect(game.scheduler.scheduledSides == [.second])
        #expect(game.view.isBoardLocked == true)
        #expect(game.view.status?.text == String(localized: .computerThinkingStatus(String(localized: .computerName))))
        #expect(game.view.players.map(\.state) == [.inactive, .active])
    }

    @Test(arguments: [
        (Difficulty.easy, "RandomPlayer"),
        (Difficulty.medium, "TacticalPlayer"),
        (Difficulty.hard, "PerfectPlayer")
    ])
    func computerPlaysAtConfiguredDifficulty(difficulty: Difficulty, playerType: String) throws {
        let game = makeGame(difficulty: difficulty)

        game.presenter.didTapCell(at: try .at(1, 1))

        let player = try #require(game.scheduler.lastPlayer)
        #expect(String(describing: type(of: player)) == playerType)
    }

    @Test func computerMoveShowsItsFigureAndUnlocksBoard() throws {
        let game = makeGame(figures: [.first: .star, .second: .heart])
        let playerCell = try Position.at(1, 1)

        game.presenter.didTapCell(at: playerCell)
        game.scheduler.runPendingMove()

        guard case .showFigure(let figure, let side, let cell) = game.view.boardEvents.last else {
            Issue.record("The computer's figure is not shown")
            return
        }
        #expect(figure == .heart)
        #expect(side == .second)
        #expect(cell != playerCell)
        #expect(game.view.isBoardLocked == false)
        #expect(game.view.status?.text == String(localized: .yourTurnStatus))
    }

    @Test func playerAndComputerMovesAreAnnounced() throws {
        let game = makeGame()
        let playerCell = try Position.at(1, 1)
        let computerCell = try Position.at(0, 0)
        let computerName = String(localized: .computerName)

        game.presenter.didTapCell(at: playerCell)
        game.scheduler.completePendingMove(at: computerCell)

        let playerMove = String(localized: .moveAnnouncement(
            String(localized: .youName),
            Figure.cross.accessibilityName,
            playerCell.accessibilityName
        ))
        let computerMove = String(localized: .moveAnnouncement(
            computerName,
            Figure.circle.accessibilityName,
            computerCell.accessibilityName
        ))
        #expect(game.view.announcements == [
            "\(playerMove). \(String(localized: .computerThinkingStatus(computerName)))",
            "\(computerMove). \(String(localized: .yourTurnStatus))"
        ])
    }

    @Test func tapsWhileComputerThinksAreIgnored() throws {
        let game = makeGame()

        game.presenter.didTapCell(at: try .at(1, 1))
        game.presenter.didTapCell(at: try .at(0, 0))

        #expect(game.view.boardEvents == [.resetBoard, .showFigure(.cross, .first, try .at(1, 1))])
        #expect(game.haptics.events == [.move])
    }

    @Test func computerMovePlaysNoHaptic() throws {
        let game = makeGame()

        game.presenter.didTapCell(at: try .at(1, 1))
        game.scheduler.runPendingMove()

        #expect(game.haptics.events == [.move])
    }

    @Test func computerWinShowsComputerResultAndLossHaptic() throws {
        let game = makeGame()

        // The computer completes the top row
        try play([(1, 0), (0, 0), (2, 2), (0, 1), (2, 0), (0, 2)], in: game)

        let computerName = String(localized: .computerName)
        #expect(game.view.status?.text == String(localized: .computerWinStatus(computerName)))
        #expect(game.view.result?.title == String(localized: .computerWinTitle))
        #expect(game.view.result?.winner == .second)
        #expect(game.view.players.map(\.score) == [0, 1])
        #expect(game.haptics.events.last == .loss)
        #expect(game.view.isBoardLocked == false)
    }

    @Test func playerWinShowsYouWin() throws {
        let game = makeGame()

        try play([(0, 0), (1, 0), (0, 1), (1, 1), (0, 2)], in: game)

        #expect(game.view.status?.text == String(localized: .youWinStatus(String(localized: .youName))))
        #expect(game.view.result?.title == String(localized: .youWinTitle))
        #expect(game.haptics.events.last == .win)
    }

    @Test func computerStartsGameAfterFinishedOne() throws {
        let game = makeGame()
        try play([(0, 0), (1, 0), (0, 1), (1, 1), (0, 2)], in: game)

        game.presenter.didTapNewGame()

        #expect(game.view.boardEvents.last == .resetBoard)
        #expect(game.scheduler.hasPendingMove)
        #expect(game.view.isBoardLocked == true)
    }

    @Test func restartWhileComputerThinksCancelsItsMove() throws {
        let game = makeGame()
        game.presenter.didTapCell(at: try .at(1, 1))
        let cancelsBefore = game.scheduler.cancelCount

        game.presenter.didTapNewGame()

        #expect(game.scheduler.cancelCount == cancelsBefore + 1)
        #expect(!game.scheduler.hasPendingMove)
        #expect(game.view.boardEvents.last == .resetBoard)
        #expect(game.view.isBoardLocked == false)
    }

    @Test func menuCancelsComputerMove() throws {
        let game = makeGame()
        game.presenter.didTapCell(at: try .at(1, 1))
        let cancelsBefore = game.scheduler.cancelCount

        game.presenter.didTapMenu()

        #expect(game.scheduler.cancelCount == cancelsBefore + 1)
        #expect(game.router.events == [.showMenu])
    }

    @Test func twoPlayersGameNeverAsksComputer() throws {
        let scheduler = ComputerMoveSchedulerFake()
        let view = GameViewSpy()
        let presenter = GamePresenter(
            configuration: GameConfiguration(mode: .twoPlayers),
            router: RouterSpy(),
            haptics: HapticsServiceSpy(),
            scheduler: scheduler
        )
        presenter.view = view
        presenter.viewDidLoad()

        presenter.didTapCell(at: try .at(1, 1))

        #expect(scheduler.scheduledSides.isEmpty)
        #expect(view.isBoardLocked == false)
    }
}

extension GamePresenterComputerTests {

    // MARK: - Game

    private struct Game {
        let presenter: GamePresenter
        let view: GameViewSpy
        let scheduler: ComputerMoveSchedulerFake
        let haptics: HapticsServiceSpy
        let router: RouterSpy
    }

    // MARK: - Private methods

    private func makeGame(difficulty: Difficulty = .medium, figures: [Side: Figure] = [:]) -> Game {
        let view = GameViewSpy()
        let scheduler = ComputerMoveSchedulerFake()
        let haptics = HapticsServiceSpy()
        let router = RouterSpy()
        let presenter = GamePresenter(
            configuration: GameConfiguration(mode: .computer, figures: figures, difficulty: difficulty),
            router: router,
            haptics: haptics,
            scheduler: scheduler
        )
        presenter.view = view
        presenter.viewDidLoad()
        return Game(presenter: presenter, view: view, scheduler: scheduler, haptics: haptics, router: router)
    }

    /// Alternates the player's taps and the computer's moves, starting with the player
    private func play(_ cells: [(Int, Int)], in game: Game) throws {
        for (index, (row, column)) in cells.enumerated() {
            let cell = try Position.at(row, column)
            if index.isMultiple(of: 2) {
                game.presenter.didTapCell(at: cell)
            } else {
                game.scheduler.completePendingMove(at: cell)
            }
        }
    }
}
