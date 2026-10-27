//
//  GameContract.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 12.09.2026.
//

protocol GameViewProtocol: AnyObject {
    func setTitle(_ title: String)
    func showFigure(_ figure: Figure, for side: Side, at position: Position)
    func resetBoard()
    func updatePlayers(_ players: [PlayerCardViewModel])
    func updateStatus(_ status: GameStatusViewModel)
    func showGameOver(_ result: GameResultViewModel, winningLine: WinningLineViewModel?)
    /// While the computer picks its move: taps are off and the free cells are dimmed
    func setBoardLocked(_ isLocked: Bool)
    /// Spoken by VoiceOver after the current speech, e.g. the move just made
    func announce(_ text: String)
}

protocol GamePresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapCell(at position: Position)
    func didTapNewGame()
    func didTapMenu()
}

protocol GameRouting: AnyObject {
    func showMenu()
}
