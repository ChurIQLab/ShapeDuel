//
//  Spacing.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 16.09.2026.
//

import CoreGraphics

enum Spacing {

    // MARK: - Properties

    static let screenMargin: CGFloat = 20
    static let betweenCards: CGFloat = 12
    static let betweenCells: CGFloat = 10
    static let cardPadding: CGFloat = 16
    static let menuItemPadding: CGFloat = 18
    /// From the content to the bottom edge of the screen
    static let minimumBottomMargin: CGFloat = 16

    // MARK: - Methods

    /// What to add above the bottom safe area: without a home indicator it is zero and the content
    /// would touch the screen edge, with a home indicator the safe area is enough
    static func bottomMargin(safeAreaInset: CGFloat) -> CGFloat {
        max(minimumBottomMargin - safeAreaInset, 0)
    }

    static func betweenBlocks(for heightClass: HeightClass) -> CGFloat {
        switch heightClass {
        case .regular: 28
        case .compact: 18
        }
    }
}
