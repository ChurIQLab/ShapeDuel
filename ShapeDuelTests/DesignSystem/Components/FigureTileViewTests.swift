//
//  FigureTileViewTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 26.09.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct FigureTileViewTests {

    @Test func tileIsButtonNamedAfterFigure() {
        let tile = FigureTileView(figure: .star, side: .first, style: .large)

        #expect(tile.isAccessibilityElement)
        #expect(tile.accessibilityLabel == Figure.star.accessibilityName)
        #expect(tile.accessibilityTraits.contains(.button))
        #expect(!tile.accessibilityTraits.contains(.selected))
        #expect(tile.accessibilityValue == nil)
    }

    @Test func selectedTileHasSelectedTrait() {
        let tile = FigureTileView(figure: .star, side: .first, style: .large)

        tile.isSelected = true

        #expect(tile.accessibilityTraits.contains(.selected))
    }

    @Test func takenTileIsDimmedAndNotEnabled() {
        let tile = FigureTileView(figure: .star, side: .second, style: .small)

        tile.isEnabled = false

        #expect(abs(tile.alpha - 0.3) < 0.001)
        #expect(tile.accessibilityTraits.contains(.notEnabled))
        #expect(tile.accessibilityValue == String(localized: .takenFigure))
    }

    @Test func freedTileLosesTakenValue() {
        let tile = FigureTileView(figure: .star, side: .second, style: .small)
        tile.isEnabled = false

        tile.isEnabled = true

        #expect(tile.accessibilityValue == nil)
        #expect(!tile.accessibilityTraits.contains(.notEnabled))
    }

    @Test func touchAreaIncludesOutset() {
        let tile = FigureTileView(figure: .star, side: .first, style: .small)
        tile.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        tile.touchOutset = 3

        #expect(tile.point(inside: CGPoint(x: -2, y: 40), with: nil))
        #expect(!tile.point(inside: CGPoint(x: -4, y: 19), with: nil))
    }
}
