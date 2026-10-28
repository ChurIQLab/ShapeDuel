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

    private let scrollView = UIScrollView()
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

        // On a large text size the header and the items do not fit and scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        itemsStackView.axis = .vertical
        itemsStackView.spacing = Spacing.betweenCards
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(itemsStackView)

        let textStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStackView.axis = .vertical
        textStackView.alignment = .center
        textStackView.spacing = Constants.textSpacing

        let headerStackView = UIStackView(arrangedSubviews: [markView, textStackView])
        headerStackView.axis = .vertical
        headerStackView.alignment = .center
        headerStackView.spacing = Constants.headerSpacing
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(headerStackView)

        setupConstraints(headerStackView: headerStackView)
    }

    private func setupConstraints(headerStackView: UIStackView) {
        // The header is centered in the space above the menu items. A view, not a layout guide:
        // a guide added to the scroll view stays in place while the content scrolls
        let headerAreaView = UIView()
        headerAreaView.isUserInteractionEnabled = false
        headerAreaView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.insertSubview(headerAreaView, at: 0)

        let safeArea = safeAreaLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        // The items stay at the bottom of the screen while everything fits
        let fittingHeight = contentGuide.heightAnchor.constraint(equalTo: frameGuide.heightAnchor)
        fittingHeight.priority = .defaultLow
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            contentGuide.heightAnchor.constraint(greaterThanOrEqualTo: frameGuide.heightAnchor),
            fittingHeight,

            itemsStackView.leadingAnchor.constraint(
                equalTo: contentGuide.leadingAnchor,
                constant: Spacing.screenMargin
            ),
            itemsStackView.trailingAnchor.constraint(
                equalTo: contentGuide.trailingAnchor,
                constant: -Spacing.screenMargin
            ),
            itemsStackView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),

            headerAreaView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            headerAreaView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            headerAreaView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            headerAreaView.bottomAnchor.constraint(equalTo: itemsStackView.topAnchor),

            headerStackView.centerYAnchor.constraint(equalTo: headerAreaView.centerYAnchor),
            headerStackView.topAnchor.constraint(greaterThanOrEqualTo: headerAreaView.topAnchor),
            headerStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: headerAreaView.bottomAnchor,
                constant: -Constants.headerSpacing
            ),
            headerStackView.leadingAnchor.constraint(
                equalTo: contentGuide.leadingAnchor,
                constant: Spacing.screenMargin
            ),
            headerStackView.trailingAnchor.constraint(
                equalTo: contentGuide.trailingAnchor,
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
