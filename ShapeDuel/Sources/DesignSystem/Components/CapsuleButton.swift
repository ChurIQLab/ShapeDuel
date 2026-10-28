//
//  CapsuleButton.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 23.09.2026.
//

import UIKit

final class CapsuleButton: UIButton {

    // MARK: - Initial

    /// On a large text size the button grows taller than `minimumHeight` and wraps its title
    init(title: String, style: Style, minimumHeight: CGFloat = Size.buttonHeight) {
        super.init(frame: .zero)
        setupView(title: title, style: style, minimumHeight: minimumHeight)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setups

    private func setupView(title: String, style: Style, minimumHeight: CGFloat) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .capsule
        configuration.contentInsets = Constants.contentInsets
        configuration.titleAlignment = .center
        configuration.baseBackgroundColor = style.backgroundColor
        configuration.baseForegroundColor = style.foregroundColor
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { [weak self] in
            var attributes = $0
            attributes.font = Typography.accent.font(compatibleWith: self?.traitCollection)
            return attributes
        }
        self.configuration = configuration
        heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight).isActive = true

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

// MARK: - Constants

extension CapsuleButton {
    struct Constants {
        /// Around a title wrapped on a large text size; on the default size the minimum height decides
        static let contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
    }
}
