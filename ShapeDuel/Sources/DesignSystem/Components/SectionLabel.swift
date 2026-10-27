//
//  SectionLabel.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 26.09.2026.
//

import UIKit

/// Uppercase label above a block: «Сложность», «Ваша фигура», «Оформление»
final class SectionLabel: UILabel {

    // MARK: - Properties

    override var text: String? {
        get { attributedText?.string }
        set {
            rawText = newValue
            updateText()
        }
    }

    /// The text as it was set, before it is uppercased
    private var rawText: String?

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        numberOfLines = 0
        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (label: SectionLabel, _: UITraitCollection) in
            label.updateText()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    /// The font and the letter spacing are in the attributed text, so it is built again for a new text size
    private func updateText() {
        guard let text = rawText else {
            attributedText = nil
            return
        }
        let font = Typography.sectionLabel.font(compatibleWith: traitCollection)
        attributedText = NSAttributedString(
            string: text.localizedUppercase,
            attributes: [
                .font: font,
                .kern: Typography.sectionLabel.tracking * font.pointSize,
                .foregroundColor: UIColor.secondaryText
            ]
        )
    }
}
