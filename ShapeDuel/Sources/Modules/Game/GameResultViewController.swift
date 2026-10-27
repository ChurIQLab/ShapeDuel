//
//  GameResultViewController.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 23.09.2026.
//

import UIKit

/// Bottom sheet with the result of a finished game. Only draws the result:
/// the button actions go to the game presenter through `onPlayAgain` and `onMenu`
final class GameResultViewController: UIViewController {

    // MARK: - Properties

    private let result: GameResultViewModel
    private let onPlayAgain: () -> Void
    private let onMenu: () -> Void
    private let sheetTransitioningDelegate = BottomSheetTransitioningDelegate()

    // MARK: - Outlets

    private let grabberView = UIView()
    private let badgeView = UIView()
    private let figuresStackView = UIStackView()
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIAccessibility.post(notification: .screenChanged, argument: titleLabel)
    }

    override func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true)
        return true
    }

    // MARK: - Initial

    init(result: GameResultViewModel, onPlayAgain: @escaping () -> Void, onMenu: @escaping () -> Void) {
        self.result = result
        self.onPlayAgain = onPlayAgain
        self.onMenu = onMenu
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = sheetTransitioningDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setups

    private func setupView() {
        setupGrabber()
        setupBadge()
        setupLabels()

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, scoreLabel])
        textStackView.axis = .vertical
        textStackView.spacing = Constants.textSpacing

        let playAgainButton = CapsuleButton(
            title: String(localized: .playAgainButton),
            style: .primary,
            height: Size.sheetButtonHeight
        )
        playAgainButton.addAction(UIAction { [weak self] _ in
            self?.playAgain()
        }, for: .touchUpInside)

        let menuButton = CapsuleButton(
            title: String(localized: .menuButton),
            style: .secondary,
            height: Size.sheetButtonHeight
        )
        menuButton.addAction(UIAction { [weak self] _ in
            self?.goToMenu()
        }, for: .touchUpInside)

        let buttonsStackView = UIStackView(arrangedSubviews: [playAgainButton, menuButton])
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = Constants.buttonSpacing

        let contentStackView = UIStackView(arrangedSubviews: [grabberView, badgeView, textStackView, buttonsStackView])
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = Constants.contentSpacing
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStackView)

        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: margins.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            textStackView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            buttonsStackView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
        ])
    }

    private func setupLabels() {
        titleLabel.text = result.title
        titleLabel.font = Typography.title.font()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .primaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityTraits = .header
        // The sheet focuses the title, so it is read together with the score
        titleLabel.accessibilityLabel = "\(result.title), \(result.score)"

        scoreLabel.text = result.score
        scoreLabel.font = Typography.body.font()
        scoreLabel.adjustsFontForContentSizeCategory = true
        scoreLabel.textColor = .secondaryText
        scoreLabel.textAlignment = .center
        scoreLabel.numberOfLines = 0
        scoreLabel.isAccessibilityElement = false
    }

    private func setupGrabber() {
        grabberView.backgroundColor = .tertiaryLabel
        grabberView.layer.cornerRadius = Constants.grabberSize.height / 2
        grabberView.isAccessibilityElement = false
        NSLayoutConstraint.activate([
            grabberView.widthAnchor.constraint(equalToConstant: Constants.grabberSize.width),
            grabberView.heightAnchor.constraint(equalToConstant: Constants.grabberSize.height)
        ])
    }

    private func setupBadge() {
        badgeView.backgroundColor = result.winner?.tintColor ?? .secondaryButton
        badgeView.layer.cornerRadius = Constants.badgeSize / 2
        badgeView.isAccessibilityElement = false

        let figureSize = result.figures.count > 1 ? Constants.pairFigureSize : Constants.singleFigureSize
        for sideFigure in result.figures {
            let figureView = FigureView()
            figureView.show(sideFigure.figure, color: sideFigure.side.color)
            NSLayoutConstraint.activate([
                figureView.widthAnchor.constraint(equalToConstant: figureSize),
                figureView.heightAnchor.constraint(equalToConstant: figureSize)
            ])
            figuresStackView.addArrangedSubview(figureView)
        }
        figuresStackView.spacing = Constants.figureSpacing
        figuresStackView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.addSubview(figuresStackView)

        NSLayoutConstraint.activate([
            badgeView.widthAnchor.constraint(equalToConstant: Constants.badgeSize),
            badgeView.heightAnchor.constraint(equalToConstant: Constants.badgeSize),
            figuresStackView.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            figuresStackView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
        ])
    }

    // MARK: - Private methods

    private func playAgain() {
        onPlayAgain()
        dismiss(animated: true)
    }

    /// The menu opens after the sheet is closed: the navigation stack cannot pop under a presented sheet
    private func goToMenu() {
        dismiss(animated: true) { [onMenu] in
            onMenu()
        }
    }
}

// MARK: - Constants

extension GameResultViewController {
    struct Constants {
        static let grabberSize = CGSize(width: 36, height: 5)
        static let badgeSize: CGFloat = 92
        static let singleFigureSize: CGFloat = 52
        static let pairFigureSize: CGFloat = 36
        static let figureSpacing: CGFloat = 2
        static let contentSpacing: CGFloat = 20
        static let textSpacing: CGFloat = 6
        static let buttonSpacing: CGFloat = 10
    }
}
