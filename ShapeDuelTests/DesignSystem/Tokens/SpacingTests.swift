//
//  SpacingTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 01.11.2026.
//

import CoreGraphics
import Testing
@testable import ShapeDuel

struct SpacingTests {

    @Test func screenWithoutHomeIndicatorGetsFullMargin() {
        #expect(Spacing.bottomMargin(safeAreaInset: 0) == Spacing.minimumBottomMargin)
    }

    @Test func homeIndicatorSafeAreaNeedsNoMargin() {
        #expect(Spacing.bottomMargin(safeAreaInset: 34) == 0)
    }

    @Test func smallSafeAreaIsToppedUpToMinimum() {
        #expect(Spacing.bottomMargin(safeAreaInset: 6) == Spacing.minimumBottomMargin - 6)
    }
}
