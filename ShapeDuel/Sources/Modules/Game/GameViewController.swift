//
//  GameViewController.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 06.10.2024.
//

import UIKit

final class GameViewController: UIViewController {

    // MARK: - Properties

    private let presenter: GamePresenterProtocol
    private let gameView = GameView()

    // MARK: - Lifecycle

    override func loadView() {
        view = gameView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        gameView.onCellTap = { [weak self] position in
            self?.presenter.didTapCell(at: position)
        }
        presenter.viewDidLoad()
    }

    // MARK: - Initial

    init(presenter: GamePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setups

    private func setupNavigationBar() {
        let restartItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.restartImageName),
            primaryAction: UIAction { [weak self] _ in
                self?.presenter.didTapNewGame()
            }
        )
        restartItem.accessibilityLabel = String(localized: .restartButton)
        navigationItem.rightBarButtonItem = restartItem
    }
}

// MARK: - GameViewProtocol

extension GameViewController: GameViewProtocol {
    func setTitle(_ title: String) {
        navigationItem.title = title
    }

    func showFigure(_ figure: Figure, for side: Side, at position: Position) {
        gameView.showFigure(figure, for: side, at: position)
    }

    func resetBoard() {
        gameView.reset()
    }

    func updatePlayers(_ players: [PlayerCardViewModel]) {
        gameView.updatePlayers(players)
    }

    func updateStatus(_ status: GameStatusViewModel) {
        gameView.updateStatus(status)
    }

    func setBoardLocked(_ isLocked: Bool) {
        gameView.setBoardLocked(isLocked)
    }

    func announce(_ text: String) {
        // Queued, so VoiceOver first finishes reading the tapped cell
        let announcement = NSAttributedString(string: text, attributes: [.accessibilitySpeechQueueAnnouncement: true])
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }

    func showGameOver(_ result: GameResultViewModel, winningLine: WinningLineViewModel?) {
        gameView.showGameOver(winningLine: winningLine) { [weak self] in
            self?.presentResult(result)
        }
    }
}

// MARK: - Private methods

extension GameViewController {
    private func presentResult(_ result: GameResultViewModel) {
        let resultViewController = GameResultViewController(
            result: result,
            onPlayAgain: { [weak self] in
                self?.presenter.didTapNewGame()
            },
            onMenu: { [weak self] in
                self?.presenter.didTapMenu()
            }
        )
        present(resultViewController, animated: true)
    }
}

// MARK: - Constants

extension GameViewController {
    struct Constants {
        static let restartImageName = "arrow.clockwise"
    }
}
