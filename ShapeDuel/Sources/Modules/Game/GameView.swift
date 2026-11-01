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
    /// The content is centered, so the margin above it keeps the same margin below it when it scrolls
    private var contentMarginConstraint: NSLayoutConstraint?
    /// Changes on every reset, so a finished game ending after a restart is not shown
    private var gameID = 0

    // MARK: - Outlets

    private let scrollView = UIScrollView()
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

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        contentMarginConstraint?.constant = Spacing.bottomMargin(safeAreaInset: safeAreaInsets.bottom)
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

        // On a large text size the content does not fit and scrolls
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = Spacing.betweenBlocks(for: .regular)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(playersStackView)
        contentStackView.addArrangedSubview(boardStackView)
        contentStackView.addArrangedSubview(statusView)
        scrollView.addSubview(contentStackView)

        winLineView.spacing = Spacing.betweenCells
        winLineView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(winLineView)

        let safeArea = safeAreaLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        let contentMarginConstraint = contentStackView.topAnchor.constraint(
            greaterThanOrEqualTo: contentGuide.topAnchor
        )
        self.contentMarginConstraint = contentMarginConstraint
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            // The content is centered while it fits, and starts at the top when it does not
            contentGuide.heightAnchor.constraint(greaterThanOrEqualTo: frameGuide.heightAnchor),
            fittingHeight(of: contentGuide.heightAnchor, equalTo: frameGuide.heightAnchor, priority: .defaultLow),
            contentStackView.leadingAnchor.constraint(
                equalTo: contentGuide.leadingAnchor,
                constant: Spacing.screenMargin
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: contentGuide.trailingAnchor,
                constant: -Spacing.screenMargin
            ),
            contentStackView.centerYAnchor.constraint(equalTo: contentGuide.centerYAnchor),
            contentMarginConstraint,
            boardStackView.heightAnchor.constraint(equalTo: boardStackView.widthAnchor),
            winLineView.topAnchor.constraint(equalTo: boardStackView.topAnchor),
            winLineView.leadingAnchor.constraint(equalTo: boardStackView.leadingAnchor),
            winLineView.trailingAnchor.constraint(equalTo: boardStackView.trailingAnchor),
            winLineView.bottomAnchor.constraint(equalTo: boardStackView.bottomAnchor)
        ])
    }

    private func setupPlayers() {
        playersStackView.spacing = Spacing.betweenCards
        playersStackView.distribution = .fillEqually
        updatePlayersAxis()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (view: GameView, _: UITraitCollection) in
            view.updatePlayersAxis()
        }

        for side in Side.allCases {
            let playerCard = PlayerCardView()
            // The card grows with the text size
            let heightConstraint = playerCard.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Size.playerCardHeight(for: .regular)
            )
            heightConstraint.isActive = true
            // Stronger than the content wish below, so a card does not stretch when the text gets smaller
            fittingHeight(of: playerCard.heightAnchor, equalTo: nil, priority: .defaultLow + 1).isActive = true
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

    /// A weak wish for the smallest height: the other constraints only set lower bounds
    private func fittingHeight(
        of anchor: NSLayoutDimension,
        equalTo other: NSLayoutDimension?,
        priority: UILayoutPriority
    ) -> NSLayoutConstraint {
        let constraint = other.map { anchor.constraint(equalTo: $0) } ?? anchor.constraint(equalToConstant: 0)
        constraint.priority = priority
        return constraint
    }

    /// Side by side; on the accessibility text sizes one under the other, so the names fit
    private func updatePlayersAxis() {
        playersStackView.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
            ? .vertical
            : .horizontal
    }

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
