//
//  MenuItemView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 25.09.2026.
//

import UIKit

/// Menu card: icon on the left, title with subtitle and a chevron on the right
final class MenuItemView: UIControl {

    // MARK: - Properties

    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? Constants.highlightedAlpha : 1
        }
    }

    // MARK: - Outlets

    private let cardView = CardView(cornerRadius: CornerRadius.menuItem)
    private let iconBackgroundView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevronImageView = UIImageView()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure(with item: MenuItemViewModel, iconName: String) {
        iconImageView.image = UIImage(systemName: iconName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        accessibilityLabel = item.title
        accessibilityHint = item.subtitle
    }

    // MARK: - Setups

    private func setupView() {
        isAccessibilityElement = true
        accessibilityTraits = .button

        cardView.isUserInteractionEnabled = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)

        setupIcon()
        setupLabels()

        chevronImageView.image = UIImage(systemName: Constants.chevronImageName)
        chevronImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: Constants.chevronPointSize,
            weight: .bold
        )
        chevronImageView.tintColor = .secondaryText
        chevronImageView.setContentHuggingPriority(.required, for: .horizontal)

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.spacing = Constants.textSpacing

        let contentStackView = UIStackView(arrangedSubviews: [iconBackgroundView, textStackView, chevronImageView])
        contentStackView.alignment = .center
        contentStackView.spacing = Constants.contentSpacing
        contentStackView.isUserInteractionEnabled = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: Size.menuItemHeight),
            contentStackView.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: Spacing.menuItemPadding
            ),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.menuItemPadding),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.menuItemPadding),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupIcon() {
        iconBackgroundView.backgroundColor = .screenBackground
        iconBackgroundView.layer.cornerRadius = Constants.iconCornerRadius
        iconBackgroundView.layer.cornerCurve = .continuous

        iconImageView.tintColor = .primaryText
        iconImageView.contentMode = .center
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            pointSize: Constants.iconPointSize,
            weight: .medium
        )
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconBackgroundView.widthAnchor.constraint(equalToConstant: Constants.iconBackgroundSize),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: Constants.iconBackgroundSize),
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor)
        ])
    }

    private func setupLabels() {
        titleLabel.font = Typography.accent.font()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .primaryText
        titleLabel.numberOfLines = 0

        subtitleLabel.font = Typography.caption.font()
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryText
        subtitleLabel.numberOfLines = 0
    }
}

// MARK: - Constants

extension MenuItemView {
    struct Constants {
        static let iconBackgroundSize: CGFloat = 48
        static let iconCornerRadius: CGFloat = 14
        static let iconPointSize: CGFloat = 20
        static let chevronImageName = "chevron.right"
        static let chevronPointSize: CGFloat = 15
        static let contentSpacing: CGFloat = 14
        static let textSpacing: CGFloat = 2
        static let highlightedAlpha: CGFloat = 0.6
    }
}
