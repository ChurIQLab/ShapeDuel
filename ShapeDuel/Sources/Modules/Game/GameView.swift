//
//  GameView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 06.10.2024.
//

import UIKit

final class GameView: UIView {

    // MARK: - Properties

    var onCellTap: ((Position) -> Void)?

    private var cells: [Position: BoardCell] = [:]
    private var playerCards: [Side: PlayerCardView] = [:]
    /// VoiceOver tells whose figure is in a cell
    private var playerNames: [Side: String] = [:]
    private var playerCardHeightConstraints: [NSLayoutConstraint] = []
    private var heightClass: HeightClass?
    /// Changes on every reset, so a finished game ending after a restart is not shown
    private var gameID = 0

    // MARK: - Outlets

    private let contentStackView = UIStackView()
    private let playersStackView = UIStackView()
    private let boardStackView = UIStackView()
    private let statusView = GameStatusView()
    private let winLineView = WinLineView()

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeightClass()
    }

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func showFigure(_ figure: Figure, for side: Side, at position: Position) {
        cells[position]?.showFigure(figure, color: side.color, ownerName: playerNames[side])
    }

    func updatePlayers(_ players: [PlayerCardViewModel]) {
        for player in players {
            playerNames[player.side] = player.name
            playerCards[player.side]?.configure(with: player)
        }
    }

    func updateStatus(_ status: GameStatusViewModel) {
        statusView.configure(with: status)
    }

    /// Draws the winning line after the last figure, then calls `completion`
    func showGameOver(winningLine: WinningLineViewModel?, completion: @escaping () -> Void) {
        var delay = FigureView.Constants.drawDuration
        if let winningLine {
            winLineView.show(winningLine, after: delay)
            delay += WinLineView.Constants.drawDuration
        }

        let gameID = gameID
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            guard let self, self.gameID == gameID else { return }
            completion()
        }
    }

    func setBoardLocked(_ isLocked: Bool) {
        UIView.animate(withDuration: Constants.lockAnimationDuration) { [cells = cells] in
            for cell in cells.values {
                cell.setLocked(isLocked)
            }
        }
    }

    func reset() {
        gameID += 1
        winLineView.hide()
        for cell in cells.values {
            cell.clear()
        }
    }

    // MARK: - Setups

    private func setupView() {
        backgroundColor = .screenBackground
        setupPlayers()
        setupBoard()

        contentStackView.axis = .vertical
        contentStackView.spacing = Spacing.betweenBlocks(for: .regular)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(playersStackView)
        contentStackView.addArrangedSubview(boardStackView)
        contentStackView.addArrangedSubview(statusView)
        addSubview(contentStackView)

        winLineView.spacing = Spacing.betweenCells
        winLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(winLineView)

        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: Spacing.screenMargin
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -Spacing.screenMargin
            ),
            contentStackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            boardStackView.heightAnchor.constraint(equalTo: boardStackView.widthAnchor),
            winLineView.topAnchor.constraint(equalTo: boardStackView.topAnchor),
            winLineView.leadingAnchor.constraint(equalTo: boardStackView.leadingAnchor),
            winLineView.trailingAnchor.constraint(equalTo: boardStackView.trailingAnchor),
            winLineView.bottomAnchor.constraint(equalTo: boardStackView.bottomAnchor)
        ])
    }

    private func setupPlayers() {
        playersStackView.axis = .horizontal
        playersStackView.spacing = Spacing.betweenCards
        playersStackView.distribution = .fillEqually

        for side in Side.allCases {
            let playerCard = PlayerCardView()
            let heightConstraint = playerCard.heightAnchor.constraint(
                equalToConstant: Size.playerCardHeight(for: .regular)
            )
            heightConstraint.isActive = true
            playerCardHeightConstraints.append(heightConstraint)
            playerCards[side] = playerCard
            playersStackView.addArrangedSubview(playerCard)
        }
    }

    private func setupBoard() {
        boardStackView.axis = .vertical
        boardStackView.spacing = Spacing.betweenCells

        for row in 0..<Board.size {
            let cellRowStackView = UIStackView()
            cellRowStackView.axis = .horizontal
            cellRowStackView.spacing = Spacing.betweenCells
            cellRowStackView.distribution = .fillEqually

            for position in Position.all where position.row == row {
                let cell = makeCell(for: position)
                cells[position] = cell
                cellRowStackView.addArrangedSubview(cell)
            }

            boardStackView.addArrangedSubview(cellRowStackView)
        }
    }

    private func makeCell(for position: Position) -> BoardCell {
        let cell = BoardCell(position: position)
        cell.heightAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        cell.addAction(UIAction { [weak self] _ in
            self?.onCellTap?(position)
        }, for: .touchUpInside)
        return cell
    }

    // MARK: - Private methods

    private func updateHeightClass() {
        guard !bounds.isEmpty else { return }
        let newHeightClass = HeightClass(screenHeight: bounds.height)
        guard newHeightClass != heightClass else { return }
        heightClass = newHeightClass
        contentStackView.spacing = Spacing.betweenBlocks(for: newHeightClass)
        for constraint in playerCardHeightConstraints {
            constraint.constant = Size.playerCardHeight(for: newHeightClass)
        }
        for cell in cells.values {
            cell.apply(newHeightClass)
        }
    }
}

// MARK: - Constants

extension GameView {
    struct Constants {
        static let lockAnimationDuration: TimeInterval = 0.2
    }
}

// MARK: - BoardCell

private final class BoardCell: UIControl {

    // MARK: - Properties

    /// Only a free cell is a button; while the computer moves it is also not enabled
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            guard isEmpty else { return .none }
            return isEnabled ? .button : [.button, .notEnabled]
        }
        set { super.accessibilityTraits = newValue }
    }

    // MARK: - Outlets

    private let cardView = CardView(cornerRadius: CornerRadius.cell(for: .regular))
    private let figureView = FigureView()
    private var figureSizeConstraint: NSLayoutConstraint?
    private var isEmpty = true

    // MARK: - Initial

    init(position: Position) {
        super.init(frame: .zero)
        setupView(position: position)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    /// `ownerName` is read by VoiceOver after the figure: «Cross, Player 1»
    func showFigure(_ figure: Figure, color: UIColor, ownerName: String?) {
        isEmpty = false
        alpha = 1
        figureView.show(figure, color: color, animated: true)
        accessibilityValue = [figure.accessibilityName, ownerName].compactMap { $0 }.joined(separator: ", ")
    }

    func clear() {
        isEmpty = true
        figureView.show(nil, color: .clear)
        accessibilityValue = String(localized: .emptyCell)
    }

    /// Only a free cell is dimmed: the figures stay bright while the computer thinks
    func setLocked(_ isLocked: Bool) {
        isEnabled = !isLocked
        alpha = isLocked && isEmpty ? Constants.lockedAlpha : 1
    }

    func apply(_ heightClass: HeightClass) {
        cardView.cornerRadius = CornerRadius.cell(for: heightClass)
        figureSizeConstraint?.constant = Size.figureInCell(for: heightClass)
    }

    // MARK: - Setups

    private func setupView(position: Position) {
        isAccessibilityElement = true
        accessibilityLabel = position.accessibilityName
        accessibilityValue = String(localized: .emptyCell)

        cardView.isUserInteractionEnabled = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        figureView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        addSubview(figureView)

        let figureSizeConstraint = figureView.widthAnchor.constraint(equalToConstant: Size.figureInCell(for: .regular))
        self.figureSizeConstraint = figureSizeConstraint
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            figureView.centerXAnchor.constraint(equalTo: centerXAnchor),
            figureView.centerYAnchor.constraint(equalTo: centerYAnchor),
            figureView.heightAnchor.constraint(equalTo: figureView.widthAnchor),
            figureSizeConstraint
        ])

        apply(.regular)
    }
}

// MARK: - BoardCell.Constants

extension BoardCell {
    struct Constants {
        static let lockedAlpha: CGFloat = 0.55
    }
}
