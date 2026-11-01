//
//  BottomSheetTransitioningDelegateTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 01.11.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct BottomSheetTransitioningDelegateTests {

    @Test func sheetFadesWithReduceMotion() {
        let delegate = BottomSheetTransitioningDelegate { true }
        let sheet = UIViewController()
        let source = UIViewController()

        let presenting = delegate.animationController(forPresented: sheet, presenting: source, source: source)

        #expect(presenting is BottomSheetFadeAnimator)
        #expect(delegate.animationController(forDismissed: sheet) is BottomSheetFadeAnimator)
    }

    @Test func sheetKeepsSystemSlideWithoutReduceMotion() {
        let delegate = BottomSheetTransitioningDelegate { false }
        let sheet = UIViewController()
        let source = UIViewController()

        #expect(delegate.animationController(forPresented: sheet, presenting: source, source: source) == nil)
        #expect(delegate.animationController(forDismissed: sheet) == nil)
    }
}
