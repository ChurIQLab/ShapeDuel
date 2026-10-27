//
//  GameSetupView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 25.09.2026.
//

import UIKit

final class GameSetupView: UIView {

    // MARK: - Properties

    var onPlayTap: (() -> Void)?
    var onNameChange: ((String, Side) -> Void)?
    var onFigureSelect: ((Figure, Side) -> Void)?
    var onDifficultySelect: ((Int) -> Void)?

    private var heightClass: HeightClass?
    private var figurePickers: [Side: FigurePickerView] = [:]
    private var difficultyControl: SegmentedControl?
    private var difficultyHintLabel: UILabel?

    // MARK: - Outlets

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let playButton = CapsuleButton(title: String(localized: .playButton), style: .primary)

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeightClass()
    }

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func showPlayers(_ players: [PlayerSetupViewModel], hint: String) {
        clearContent()

        let fieldViews = players.map { player in
            let fieldView = NameFieldView()
            fieldView.configure(with: player.nameField)
            fieldView.onTextChange = { [weak self] name in
                self?.onNameChange?(name, player.nameField.side)
            }
            let pickerView = makeFigurePicker(with: player.figurePicker, style: .small)
            // The tiles follow the name field: VoiceOver names the player when it enters them
            pickerView.accessibilityLabel = String(localized: .playerFigures(player.nameField.label))
            contentStackView.addArrangedSubview(makeSection(of: [fieldView, pickerView]))
            return fieldView
        }

        // Return moves to the next field, the last one only hides the keyboard
        for (fieldView, nextFieldView) in zip(fieldViews, fieldViews.dropFirst()) {
            fieldView.returnKeyType = .next
            fieldView.onReturn = { [weak nextFieldView] in
                nextFieldView?.focus()
            }
        }
        fieldViews.last?.returnKeyType = .done
        fieldViews.last?.onReturn = { [weak self] in
            self?.endEditing(true)
        }

        contentStackView.addArrangedSubview(makeHintLabel(text: hint))
    }

    func showComputerSetup(_ setup: ComputerSetupViewModel) {
        clearContent()

        let difficultyControl = SegmentedControl(
            titles: setup.difficulty.titles,
            selectedIndex: setup.difficulty.selectedIndex
        )
        difficultyControl.addAction(UIAction { [weak self, weak difficultyControl] _ in
            guard let index = difficultyControl?.selectedIndex else { return }
            self?.onDifficultySelect?(index)
        }, for: .valueChanged)
        let difficultyHintLabel = makeHintLabel(text: setup.difficulty.hint)
        self.difficultyControl = difficultyControl
        self.difficultyHintLabel = difficultyHintLabel
        contentStackView.addArrangedSubview(makeSection(of: [
            makeSectionLabel(text: setup.difficultyLabel),
            difficultyControl,
            difficultyHintLabel
        ]))

        let pickerView = makeFigurePicker(with: setup.figurePicker, style: .large)
        contentStackView.addArrangedSubview(makeSection(of: [
            makeSectionLabel(text: setup.figureLabel),
            pickerView,
            makeHintLabel(text: setup.figureHint)
        ]))
    }

    func updateFigurePickers(_ pickers: [FigurePickerViewModel]) {
        for picker in pickers {
            figurePickers[picker.side]?.configure(with: picker)
        }
    }

    func updateDifficultyPicker(_ picker: DifficultyPickerViewModel) {
        difficultyControl?.setSelectedIndex(picker.selectedIndex, animated: true)
        difficultyHintLabel?.text = picker.hint
    }

    // MARK: - Setups

    private func setupView() {
        backgroundColor = .screenBackground

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapRecognizer)

        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        playButton.addAction(UIAction { [weak self] _ in
            self?.onPlayTap?()
        }, for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playButton)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide

        // The button sits on the bottom of the safe area and rises above the keyboard when it shows
        keyboardLayoutGuide.usesBottomSafeArea = false
        let buttonAtSafeAreaBottom = playButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        buttonAtSafeAreaBottom.priority = .defaultHigh

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -Constants.buttonSpacing),

            contentStackView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: Constants.contentTopInset),
            contentStackView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            contentStackView.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor,
                constant: Spacing.screenMargin
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor,
                constant: -Spacing.screenMargin
            ),
            contentGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            playButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: Spacing.screenMargin),
            playButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -Spacing.screenMargin),
            playButton.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor),
            playButton.bottomAnchor.constraint(
                lessThanOrEqualTo: keyboardLayoutGuide.topAnchor,
                constant: -Constants.buttonSpacing
            ),
            buttonAtSafeAreaBottom
        ])
    }

    // MARK: - Private methods

    private func clearContent() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        figurePickers = [:]
        difficultyControl = nil
        difficultyHintLabel = nil
    }

    private func makeFigurePicker(with viewModel: FigurePickerViewModel, style: FigureTileView.Style) -> UIView {
        let pickerView = FigurePickerView(side: viewModel.side, style: style)
        pickerView.configure(with: viewModel)
        pickerView.onSelect = { [weak self] figure in
            self?.onFigureSelect?(figure, viewModel.side)
        }
        figurePickers[viewModel.side] = pickerView
        return pickerView
    }

    /// Views of one block, closer to each other than the blocks
    private func makeSection(of views: [UIView]) -> UIView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = Constants.sectionSpacing
        return stackView
    }

    private func makeSectionLabel(text: String) -> SectionLabel {
        let label = SectionLabel()
        label.text = text
        return label
    }

    private func makeHintLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = Typography.caption.font()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryText
        label.numberOfLines = 0
        return label
    }

    private func updateHeightClass() {
        guard !bounds.isEmpty else { return }
        let newHeightClass = HeightClass(screenHeight: bounds.height)
        guard newHeightClass != heightClass else { return }
        heightClass = newHeightClass
        contentStackView.spacing = Spacing.betweenBlocks(for: newHeightClass)
    }

    @objc private func hideKeyboard() {
        endEditing(true)
    }
}

// MARK: - Constants

extension GameSetupView {
    struct Constants {
        static let contentTopInset: CGFloat = 24
        /// Between the button and the content above it or the keyboard below it
        static let buttonSpacing: CGFloat = 12
        static let sectionSpacing: CGFloat = 10
    }
}
