//
//  SegmentedControl.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 26.09.2026.
//

import UIKit

/// Capsule track with equal segments; the selected one sits on a sliding thumb.
/// A tap selects a segment and sends `valueChanged`; setting `selectedIndex` in code sends nothing.
/// The style sets the size and colors for the screen background or for a card
final class SegmentedControl: UIControl {

    // MARK: - Properties

    private(set) var selectedIndex: Int

    private let style: Style
    private let segments: [Segment]

    // MARK: - Outlets

    private let thumbView = UIView()
    private let segmentsStackView = UIStackView()

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        thumbView.layer.cornerRadius = (bounds.height - Constants.padding * 2) / 2
        updateThumbFrame()
    }

    // MARK: - Initial

    init(titles: [String], selectedIndex: Int = 0, style: Style = .onBackground) {
        self.style = style
        segments = titles.map { Segment(title: $0, font: style.font) }
        self.selectedIndex = titles.indices.contains(selectedIndex) ? selectedIndex : 0
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func setSelectedIndex(_ index: Int, animated: Bool) {
        guard segments.indices.contains(index) else { return }
        selectedIndex = index
        updateSegments()

        guard animated, window != nil else {
            setNeedsLayout()
            return
        }
        UIView.animate(
            withDuration: Constants.animationDuration,
            delay: 0,
            usingSpringWithDamping: Constants.springDamping,
            initialSpringVelocity: 0
        ) { [weak self] in
            self?.updateThumbFrame()
        }
    }

    // MARK: - Setups

    private func setupView() {
        // Like the system segmented control: the track keeps its height, the titles stop growing at xxxL
        maximumContentSizeCategory = Constants.maximumContentSizeCategory

        backgroundColor = style.trackColor
        layer.cornerCurve = .continuous

        thumbView.backgroundColor = style.thumbColor
        thumbView.layer.cornerCurve = .continuous
        thumbView.isUserInteractionEnabled = false
        addSubview(thumbView)

        segmentsStackView.distribution = .fillEqually
        segmentsStackView.spacing = Constants.spacing
        segmentsStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(segmentsStackView)

        for (index, segment) in segments.enumerated() {
            segment.addAction(UIAction { [weak self] _ in
                self?.selectFromTap(index)
            }, for: .touchUpInside)
            segmentsStackView.addArrangedSubview(segment)
        }
        accessibilityElements = segments
        // The titles stop growing at xxxL, so on larger sizes a long press shows the title enlarged
        addInteraction(UILargeContentViewerInteraction())

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: style.height),
            segmentsStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.padding),
            segmentsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
            segmentsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
            segmentsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.padding)
        ])

        updateSegments()
        updateShadow()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (control: SegmentedControl, _: UITraitCollection) in
            control.updateShadow()
        }
    }

    // MARK: - Private methods

    private func selectFromTap(_ index: Int) {
        guard index != selectedIndex else { return }
        setSelectedIndex(index, animated: true)
        sendActions(for: .valueChanged)
    }

    private func updateSegments() {
        for (index, segment) in segments.enumerated() {
            segment.isSelected = index == selectedIndex
        }
    }

    /// The stack view lays out the segments, the thumb takes the frame of the selected one
    private func updateThumbFrame() {
        segmentsStackView.layoutIfNeeded()
        guard segments.indices.contains(selectedIndex) else { return }
        thumbView.frame = segmentsStackView.convert(segments[selectedIndex].frame, to: self)
    }

    private func updateShadow() {
        Shadow.segmentThumb.apply(to: thumbView.layer, for: traitCollection)
    }
}

// MARK: - Segment

extension SegmentedControl {
    private final class Segment: UIControl {

        // MARK: - Properties

        override var isSelected: Bool {
            didSet {
                titleLabel.textColor = isSelected ? .primaryText : .secondaryText
            }
        }

        override var accessibilityTraits: UIAccessibilityTraits {
            get { isSelected ? [.button, .selected] : .button }
            set { super.accessibilityTraits = newValue }
        }

        // MARK: - Outlets

        private let titleLabel = UILabel()

        // MARK: - Initial

        init(title: String, font: UIFont) {
            super.init(frame: .zero)
            setupView(title: title, font: font)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Setups

        private func setupView(title: String, font: UIFont) {
            isAccessibilityElement = true
            accessibilityLabel = title
            showsLargeContentViewer = true
            largeContentTitle = title

            titleLabel.text = title
            titleLabel.font = font
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.textColor = .secondaryText
            titleLabel.textAlignment = .center
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = Constants.minimumTitleScale
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(titleLabel)

            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.titleInset),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.titleInset)
            ])
        }
    }
}

// MARK: - Style

extension SegmentedControl {
    enum Style {
        case onBackground
        case inCard

        // MARK: - Properties

        var height: CGFloat {
            switch self {
            case .onBackground: Size.segmentedControlHeight
            case .inCard: Size.segmentedControlHeightInCard
            }
        }

        fileprivate var trackColor: UIColor {
            switch self {
            case .onBackground: .segmentTrack
            case .inCard: .segmentTrackInCard
            }
        }

        fileprivate var thumbColor: UIColor {
            switch self {
            case .onBackground: .segmentThumb
            case .inCard: .segmentThumbInCard
            }
        }

        fileprivate var font: UIFont {
            switch self {
            case .onBackground: Typography.captionBold.font()
            case .inCard: Typography.segmentInCard.font()
            }
        }
    }
}

// MARK: - Constants

extension SegmentedControl {
    struct Constants {
        /// Between the track and the thumb
        static let padding: CGFloat = 3
        static let spacing: CGFloat = 2
        static let titleInset: CGFloat = 4
        static let minimumTitleScale: CGFloat = 0.7
        static let animationDuration: TimeInterval = 0.3
        static let springDamping: CGFloat = 0.85
        static let maximumContentSizeCategory: UIContentSizeCategory = .extraExtraExtraLarge
    }
}
