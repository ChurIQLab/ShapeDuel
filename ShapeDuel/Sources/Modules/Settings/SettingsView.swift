//
//  SettingsView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 25.09.2026.
//

import UIKit

final class SettingsView: UIView {

    // MARK: - Properties

    var onThemeSelect: ((Int) -> Void)?
    var onHapticsChange: ((Bool) -> Void)?

    // MARK: - Outlets

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let footerLabel = UILabel()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func show(_ settings: SettingsViewModel) {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStackView.addArrangedSubview(makeSection(
            label: settings.appearanceLabel,
            card: makeThemeCard(with: settings.themePicker)
        ))
        contentStackView.addArrangedSubview(makeSection(
            label: settings.gameLabel,
            card: makeHapticsCard(with: settings.hapticsSwitch)
        ))
        footerLabel.text = settings.footer
    }

    // MARK: - Setups

    private func setupView() {
        backgroundColor = .screenBackground

        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = Constants.betweenSections
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        footerLabel.font = Typography.small.font()
        footerLabel.adjustsFontForContentSizeCategory = true
        footerLabel.textColor = .secondaryText
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(footerLabel)

        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: Constants.contentTopInset),
            contentStackView.leadingAnchor.constraint(
                equalTo: frameGuide.leadingAnchor,
                constant: Spacing.screenMargin
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: frameGuide.trailingAnchor,
                constant: -Spacing.screenMargin
            ),
            contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),

            // The footer sits at the bottom of the screen and follows the content when it does not fit
            contentGuide.heightAnchor.constraint(greaterThanOrEqualTo: frameGuide.heightAnchor),
            footerLabel.topAnchor.constraint(
                greaterThanOrEqualTo: contentStackView.bottomAnchor,
                constant: Constants.footerMinTopSpacing
            ),
            footerLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            footerLabel.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor)
        ])
    }

    // MARK: - Private methods

    /// A section label above its card
    private func makeSection(label text: String, card: UIView) -> UIView {
        let label = SectionLabel()
        label.text = text
        let stackView = UIStackView(arrangedSubviews: [label, card])
        stackView.axis = .vertical
        stackView.spacing = Constants.labelSpacing
        return stackView
    }

    private func makeThemeCard(with picker: ThemePickerViewModel) -> UIView {
        let titleLabel = makeTitleLabel(text: picker.title)
        let control = SegmentedControl(titles: picker.titles, selectedIndex: picker.selectedIndex, style: .inCard)
        control.addAction(UIAction { [weak self, weak control] _ in
            guard let index = control?.selectedIndex else { return }
            self?.onThemeSelect?(index)
        }, for: .valueChanged)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, control])
        stackView.axis = .vertical
        stackView.spacing = Constants.themeCardSpacing
        return makeCard(containing: stackView)
    }

    /// The title and the switch in one row; VoiceOver reads them as one switch
    private func makeHapticsCard(with row: SwitchRowViewModel) -> UIView {
        let titleLabel = makeTitleLabel(text: row.title)
        titleLabel.isAccessibilityElement = false
        let hapticsSwitch = UISwitch()
        hapticsSwitch.isOn = row.isOn
        hapticsSwitch.accessibilityLabel = row.title
        hapticsSwitch.addAction(UIAction { [weak self, weak hapticsSwitch] _ in
            guard let isOn = hapticsSwitch?.isOn else { return }
            self?.onHapticsChange?(isOn)
        }, for: .valueChanged)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, hapticsSwitch])
        stackView.alignment = .center
        stackView.spacing = Constants.switchRowSpacing
        let cardView = makeCard(containing: stackView, verticalPadding: Constants.switchRowVerticalPadding)
        cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.switchRowHeight).isActive = true
        return cardView
    }

    private func makeCard(containing contentView: UIView, verticalPadding: CGFloat = Spacing.cardPadding) -> UIView {
        let cardView = CardView(cornerRadius: CornerRadius.settingsCard)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: verticalPadding),
            contentView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Spacing.cardPadding),
            contentView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Spacing.cardPadding),
            contentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -verticalPadding)
        ])
        return cardView
    }

    private func makeTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Typography.accent.font()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .primaryText
        label.numberOfLines = 0
        return label
    }
}

// MARK: - Constants

extension SettingsView {
    struct Constants {
        static let contentTopInset: CGFloat = 24
        static let betweenSections: CGFloat = 24
        /// Between a section label and its card
        static let labelSpacing: CGFloat = 10
        /// Between the card title and the segments
        static let themeCardSpacing: CGFloat = 12
        static let switchRowHeight: CGFloat = 60
        /// The row is 60 high with the 31-point switch in the middle
        static let switchRowVerticalPadding: CGFloat = 8
        static let switchRowSpacing: CGFloat = 12
        static let footerMinTopSpacing: CGFloat = 24
    }
}
