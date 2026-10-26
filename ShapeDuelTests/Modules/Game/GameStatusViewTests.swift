//
//  GameStatusViewTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 26.10.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct GameStatusViewTests {

    @Test func statusIsOneElementWithPlainText() {
        let statusView = GameStatusView()
        let status = GameStatusViewModel(side: .first, figure: .cross, name: "Anna") { "Turn: \($0)" }

        statusView.configure(with: status)

        #expect(statusView.isAccessibilityElement)
        #expect(statusView.accessibilityLabel == "Turn: Anna")
        #expect(statusView.accessibilityTraits.contains(.updatesFrequently))
    }
}
