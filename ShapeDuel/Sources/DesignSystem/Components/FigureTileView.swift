//
//  FigureTileView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 26.09.2026.
//

import UIKit

/// A square tile with a figure in the color of a side. Selected — highlighted like the active player card;
/// disabled — the figure is taken by the opponent and dimmed
final class FigureTileView: UIControl {

    // MARK: - Properties

    let figure: Figure

    /// Extends the touch area beyond the bounds, e.g. over the gaps between small tiles
    var touchOutset: CGFloat = 0

    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            var traits = super.accessibilityTraits.union(.button)
            if isSelected {
                traits.insert(.selected)
            }
            if !isEnabled {
                traits.insert(.notEnabled)
            }
            return traits
        }
        set { super.accessibilityTraits = newValue }
    }

    private let side: Side
    private let style: Style

    // MARK: - Outlets

    private let cardView: CardView
    private let figureView = FigureView()

    // MARK: - Initial

    init(figure: Figure, side: Side, style: Style) {
        self.figure = figure
        self.side = side
        self.style = style
        cardView = CardView(cornerRadius: style.cornerRadius)
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -touchOutset, dy: -touchOutset).contains(point)
    }

    // MARK: - Setups

    private func setupView() {
        isAccessibilityElement = true
        accessibilityLabel = figure.accessibilityName

        cardView.isUserInteractionEnabled = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)

        figureView.show(figure, color: side.color)
        figureView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(figureView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor),

            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),

            figureView.centerXAnchor.constraint(equalTo: centerXAnchor),
            figureView.centerYAnchor.constraint(equalTo: centerYAnchor),
            figureView.widthAnchor.constraint(equalToConstant: style.figureSize),
            figureView.heightAnchor.constraint(equalTo: figureView.widthAnchor)
        ])

        updateAppearance()
    }

    // MARK: - Private methods

    private func updateAppearance() {
        cardView.highlight = isSelected
            ? CardView.Highlight(fillColor: side.tintColor, borderColor: side.color)
            : nil
        alpha = isEnabled ? 1 : Constants.disabledAlpha
        accessibilityValue = isEnabled ? nil : String(localized: .takenFigure)
    }
}

// MARK: - Style

extension FigureTileView {
    enum Style {
        /// 4 tiles in a row
        case large
        /// 8 tiles in a row
        case small

        var cornerRadius: CGFloat {
            switch self {
            case .large: CornerRadius.figureTile
            case .small: CornerRadius.smallFigureTile
            }
        }

        var figureSize: CGFloat {
            switch self {
            case .large: Size.figureInTile
            case .small: Size.figureInSmallTile
            }
        }
    }
}

// MARK: - Constants

extension FigureTileView {
    struct Constants {
        /// The opponent's figure
        static let disabledAlpha: CGFloat = 0.3
    }
}
