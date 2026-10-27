//
//  NameFieldView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 25.09.2026.
//

import UIKit

/// Section label above a text field on a card
final class NameFieldView: UIView {

    // MARK: - Properties

    var onTextChange: ((String) -> Void)?
    var onReturn: (() -> Void)?

    var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }

    private var maxLength = Int.max

    // MARK: - Outlets

    private let label = SectionLabel()
    private let cardView = CardView(cornerRadius: CornerRadius.textField)
    private let textField = InsetTextField()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure(with viewModel: NameFieldViewModel) {
        maxLength = viewModel.maxLength

        label.text = viewModel.label
        textField.text = viewModel.text

        textField.attributedPlaceholder = NSAttributedString(
            string: viewModel.placeholder,
            attributes: [.foregroundColor: UIColor.secondaryText]
        )
        textField.accessibilityLabel = viewModel.label
    }

    func focus() {
        textField.becomeFirstResponder()
    }

    // MARK: - Setups

    private func setupView() {
        label.isAccessibilityElement = false

        textField.font = Typography.body.font()
        textField.adjustsFontForContentSizeCategory = true
        textField.textColor = .primaryText
        textField.tintColor = .primaryText
        textField.autocapitalizationType = .words
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.delegate = self
        textField.addAction(UIAction { [weak self] _ in
            self?.textDidChange()
        }, for: .editingChanged)

        let stackView = UIStackView(arrangedSubviews: [label, cardView])
        stackView.axis = .vertical
        stackView.spacing = Constants.labelSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        textField.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(textField)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            cardView.heightAnchor.constraint(equalToConstant: Size.textFieldHeight),

            textField.topAnchor.constraint(equalTo: cardView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
    }

    // MARK: - Private methods

    /// Cuts pasted or typed text to the limit; text still being composed by the keyboard is left alone
    private func textDidChange() {
        if textField.markedTextRange == nil, let text = textField.text, text.count > maxLength {
            textField.text = String(text.prefix(maxLength))
        }
        onTextChange?(textField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate

extension NameFieldView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?()
        return false
    }

    /// Hides AutoFill: it offers the owner's contacts, while the names belong to the players
    func textField(
        _ textField: UITextField,
        editMenuForCharactersIn range: NSRange,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        UIMenu(children: removingAutoFill(from: suggestedActions))
    }

    /// AutoFill sits inside one of the standard groups, so the whole tree is filtered
    private func removingAutoFill(from elements: [UIMenuElement]) -> [UIMenuElement] {
        elements.compactMap { element in
            guard let menu = element as? UIMenu else { return element }
            guard menu.identifier != .autoFill else { return nil }
            return menu.replacingChildren(removingAutoFill(from: menu.children))
        }
    }
}

// MARK: - InsetTextField

extension NameFieldView {
    /// Fills the whole card so a tap anywhere on it starts editing, with the text inset from the edges
    private final class InsetTextField: UITextField {
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            bounds.insetBy(dx: Spacing.cardPadding, dy: 0)
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            textRect(forBounds: bounds)
        }

        override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            textRect(forBounds: bounds)
        }
    }
}

// MARK: - Constants

extension NameFieldView {
    struct Constants {
        static let labelSpacing: CGFloat = 10
    }
}
