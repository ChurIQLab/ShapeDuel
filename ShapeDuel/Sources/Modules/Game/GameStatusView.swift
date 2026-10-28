//
//  GameStatusView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 23.09.2026.
//

import UIKit

final class GameStatusView: UIView {

    // MARK: - Properties

    private var status: GameStatusViewModel?

    // MARK: - Outlets

    private let textLabel = UILabel()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure(with status: GameStatusViewModel) {
        self.status = status
        updateText()
    }

    // MARK: - Setups

    private func setupView() {
        // One element with the plain text: VoiceOver does not read the figure image inside the label
        isAccessibilityElement = true
        accessibilityTraits = .updatesFrequently

        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),
            textLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        registerForTraitChanges(
            [UITraitUserInterfaceStyle.self, UITraitPreferredContentSizeCategory.self]
        ) { (view: GameStatusView, _: UITraitCollection) in
            view.updateText()
        }
    }

    // MARK: - Private methods

    /// The figure is an image in the text, so it keeps its place in any word order of a translation
    private func updateText() {
        guard let status else {
            textLabel.attributedText = nil
            return
        }

        let textFont = Typography.body.font(compatibleWith: traitCollection)
        let text = NSMutableAttributedString(string: status.text, attributes: [
            .font: textFont,
            .foregroundColor: UIColor.secondaryText
        ])
        accessibilityLabel = status.text

        guard let player = status.player else {
            textLabel.attributedText = text
            return
        }

        text.addAttributes([
            .font: Typography.accent.font(compatibleWith: traitCollection),
            .foregroundColor: UIColor.primaryText
        ], range: player.nameRange)

        let color = player.side.color.resolvedColor(with: traitCollection)
        // The figure grows with the text around it
        let figureSize = UIFontMetrics(forTextStyle: .body).scaledValue(
            for: Size.figureInStatus,
            compatibleWith: traitCollection
        )
        let attachment = NSTextAttachment(image: player.figure.image(size: figureSize, color: color))
        attachment.bounds = CGRect(
            x: 0,
            y: (textFont.capHeight - figureSize) / 2,
            width: figureSize,
            height: figureSize
        )
        let figure = NSMutableAttributedString(attachment: attachment)
        figure.append(NSAttributedString(string: " ", attributes: [.font: textFont]))
        text.insert(figure, at: player.nameRange.location)

        textLabel.attributedText = text
    }
}

// MARK: - Constants

extension GameStatusView {
    struct Constants {
        static let minimumHeight: CGFloat = 28
    }
}
