//
//  PlayerCardView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 23.09.2026.
//

import UIKit

final class PlayerCardView: UIView {

    // MARK: - Outlets

    private let cardView = CardView(cornerRadius: CornerRadius.playerCard)
    private let figureView = FigureView()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()
    private let contentStackView = UIStackView()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure(with viewModel: PlayerCardViewModel) {
        figureView.show(viewModel.figure, color: viewModel.side.color)
        nameLabel.text = viewModel.name
        scoreLabel.text = viewModel.score.formatted()

        let textColor: UIColor = viewModel.state == .inactive ? .secondaryText : .primaryText
        nameLabel.textColor = textColor
        scoreLabel.textColor = textColor

        let isHighlighted = viewModel.state == .active || viewModel.state == .winner
        cardView.highlight = isHighlighted
            ? CardView.Highlight(fillColor: viewModel.side.tintColor, borderColor: viewModel.side.color)
            : nil

        accessibilityLabel = "\(viewModel.name), \(viewModel.figure.accessibilityName)"
        accessibilityValue = accessibilityValue(for: viewModel)
    }

    // MARK: - Setups

    private func setupView() {
        isAccessibilityElement = true

        nameLabel.font = Typography.captionBold.font()
        // «Компьютер» fits on a narrow card, a long name still ends with an ellipsis
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = Constants.minimumNameScale
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scoreLabel.font = Typography.score.font()
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = Constants.contentSpacing
        for subview in [figureView, nameLabel, scoreLabel] {
            contentStackView.addArrangedSubview(subview)
        }

        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.cardPadding),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.cardPadding),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            figureView.widthAnchor.constraint(equalToConstant: Size.figureInCard),
            figureView.heightAnchor.constraint(equalToConstant: Size.figureInCard)
        ])
    }
}

// MARK: - Private methods

extension PlayerCardView {
    /// «Moves now, score: 2»: the state is read before the score
    private func accessibilityValue(for viewModel: PlayerCardViewModel) -> String {
        let score = String(localized: .playerScore(viewModel.score))
        switch viewModel.state {
        case .active: return "\(String(localized: .movingPlayer)), \(score)"
        case .winner: return "\(String(localized: .winnerPlayer)), \(score)"
        case .inactive, .neutral: return score
        }
    }
}

// MARK: - Constants

extension PlayerCardView {
    struct Constants {
        static let contentSpacing: CGFloat = 10
        static let minimumNameScale: CGFloat = 0.75
    }
}
