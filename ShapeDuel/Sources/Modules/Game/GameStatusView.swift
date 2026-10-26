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
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumHeight),
            textLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: GameStatusView, _: UITraitCollection) in
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

        let textFont = Typography.body.font()
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
            .font: Typography.accent.font(),
            .foregroundColor: UIColor.primaryText
        ], range: player.nameRange)

        let color = player.side.color.resolvedColor(with: traitCollection)
        let attachment = NSTextAttachment(image: player.figure.image(size: Size.figureInStatus, color: color))
        attachment.bounds = CGRect(
            x: 0,
            y: (textFont.capHeight - Size.figureInStatus) / 2,
            width: Size.figureInStatus,
            height: Size.figureInStatus
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
