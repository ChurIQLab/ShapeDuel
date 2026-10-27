//
//  FigurePickerView.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 26.09.2026.
//

import UIKit

/// All figures in the color of one side: a row of 8 small tiles or a grid of 4×2 large ones
final class FigurePickerView: UIView {

    // MARK: - Properties

    var onSelect: ((Figure) -> Void)?

    private let side: Side
    private let style: FigureTileView.Style
    private let tiles: [FigureTileView]

    // MARK: - Initial

    init(side: Side, style: FigureTileView.Style) {
        self.side = side
        self.style = style
        tiles = Figure.allCases.map { FigureTileView(figure: $0, side: side, style: style) }
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure(with viewModel: FigurePickerViewModel) {
        for tile in tiles {
            tile.isSelected = tile.figure == viewModel.selected
            tile.isEnabled = tile.figure != viewModel.taken
        }
    }

    // MARK: - Setups

    private func setupView() {
        // VoiceOver reads `accessibilityLabel` of the picker when the focus moves onto its tiles
        accessibilityContainerType = .semanticGroup

        let spacing = style.spacing
        for tile in tiles {
            tile.touchOutset = spacing / 2
            tile.addAction(UIAction { [weak self, weak tile] _ in
                guard let figure = tile?.figure else { return }
                self?.onSelect?(figure)
            }, for: .touchUpInside)
        }

        let rows = stride(from: 0, to: tiles.count, by: style.columns).map { start in
            let row = UIStackView(arrangedSubviews: Array(tiles[start..<min(start + style.columns, tiles.count)]))
            row.distribution = .fillEqually
            row.spacing = spacing
            return row
        }
        let stackView = UIStackView(arrangedSubviews: rows)
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - FigureTileView.Style

private extension FigureTileView.Style {
    var columns: Int {
        switch self {
        case .large: 4
        case .small: 8
        }
    }

    var spacing: CGFloat {
        switch self {
        case .large: 10
        case .small: 6
        }
    }
}
