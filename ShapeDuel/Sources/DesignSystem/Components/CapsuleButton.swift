//
//  CapsuleButton.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 23.09.2026.
//

import UIKit

final class CapsuleButton: UIButton {

    // MARK: - Initial

    init(title: String, style: Style, height: CGFloat = Size.buttonHeight) {
        super.init(frame: .zero)
        setupView(title: title, style: style, height: height)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setups

    private func setupView(title: String, style: Style, height: CGFloat) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .capsule
        configuration.baseBackgroundColor = style.backgroundColor
        configuration.baseForegroundColor = style.foregroundColor
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak self] in
            var attributes = $0
            attributes.font = Typography.accent.font(compatibleWith: self?.traitCollection)
            return attributes
        }
        self.configuration = configuration
        heightAnchor.constraint(equalToConstant: height).isActive = true

        // The transformer sets the font, so it runs again for a new text size
        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (button: CapsuleButton, _: UITraitCollection) in
            button.setNeedsUpdateConfiguration()
        }
    }
}

// MARK: - Style

extension CapsuleButton {
    enum Style {
        case primary
        case secondary

        var backgroundColor: UIColor {
            switch self {
            case .primary: .primaryButton
            case .secondary: .secondaryButton
            }
        }

        var foregroundColor: UIColor {
            switch self {
            case .primary: .primaryButtonText
            case .secondary: .primaryText
            }
        }
    }
}
