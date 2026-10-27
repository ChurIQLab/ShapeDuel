//
//  MenuView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 25.09.2026.
//

import UIKit

final class MenuView: UIView {

    // MARK: - Properties

    var onItemTap: ((GameMode) -> Void)?

    // MARK: - Outlets

    private let markView = DuelMarkView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let itemsStackView = UIStackView()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func showItems(_ items: [MenuItemViewModel]) {
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            let itemView = MenuItemView()
            itemView.configure(with: item, iconName: iconName(for: item.mode))
            itemView.addAction(UIAction { [weak self] _ in
                self?.onItemTap?(item.mode)
            }, for: .touchUpInside)
            itemsStackView.addArrangedSubview(itemView)
        }
    }

    // MARK: - Setups

    private func setupView() {
        backgroundColor = .screenBackground
        setupHeader()

        itemsStackView.axis = .vertical
        itemsStackView.spacing = Spacing.betweenCards
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(itemsStackView)

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.alignment = .center
        textStackView.spacing = Constants.textSpacing

        let headerStackView = UIStackView(arrangedSubviews: [markView, textStackView])
        headerStackView.axis = .vertical
        headerStackView.alignment = .center
        headerStackView.spacing = Constants.headerSpacing
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerStackView)

        // The header is centered in the space above the menu items
        let headerAreaGuide = UILayoutGuide()
        addLayoutGuide(headerAreaGuide)

        let safeArea = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            itemsStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Spacing.screenMargin),
            itemsStackView.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -Spacing.screenMargin
            ),
            itemsStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),

            headerAreaGuide.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerAreaGuide.bottomAnchor.constraint(equalTo: itemsStackView.topAnchor),

            headerStackView.centerYAnchor.constraint(equalTo: headerAreaGuide.centerYAnchor),
            headerStackView.topAnchor.constraint(greaterThanOrEqualTo: headerAreaGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Spacing.screenMargin),
            headerStackView.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -Spacing.screenMargin
            ),

            markView.widthAnchor.constraint(equalToConstant: Size.menuIcon),
            markView.heightAnchor.constraint(equalToConstant: Size.menuIcon)
        ])
    }

    private func setupHeader() {
        markView.isAccessibilityElement = false

        titleLabel.text = String(localized: .appTitle)
        titleLabel.font = Typography.largeTitle.font()
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .primaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityTraits = .header

        subtitleLabel.text = String(localized: .appSubtitle)
        subtitleLabel.font = Typography.body.font()
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryText
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
    }

    // MARK: - Private methods

    private func iconName(for mode: GameMode) -> String {
        switch mode {
        case .computer: Constants.computerImageName
        case .twoPlayers: Constants.twoPlayersImageName
        }
    }
}

// MARK: - Constants

extension MenuView {
    struct Constants {
        static let headerSpacing: CGFloat = 18
        static let textSpacing: CGFloat = 4
        static let computerImageName = "desktopcomputer"
        static let twoPlayersImageName = "person.2"
    }
}
