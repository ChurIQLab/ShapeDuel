//
//  PositionNameTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 22.10.2026.
//

import Testing
@testable import ShapeDuel

struct PositionNameTests {

    @Test func everyCellHasItsOwnName() {
        let names = Position.all.map(\.accessibilityName)

        #expect(Set(names).count == Position.all.count)
        #expect(!names.contains(""))
    }

    @Test func cornersAndCenterAreNamedByPlace() throws {
        let topLeft = try #require(Position(row: 0, column: 0))
        let center = try #require(Position(row: 1, column: 1))
        let bottomRight = try #require(Position(row: 2, column: 2))

        #expect(topLeft.accessibilityName == String(localized: .topLeftCell))
        #expect(center.accessibilityName == String(localized: .centerCell))
        #expect(bottomRight.accessibilityName == String(localized: .bottomRightCell))
    }

    @Test func middleOfTopRowIsNotMixedUpWithMiddleOfLeftColumn() throws {
        let top = try #require(Position(row: 0, column: 1))
        let left = try #require(Position(row: 1, column: 0))

        #expect(top.accessibilityName == String(localized: .topCell))
        #expect(left.accessibilityName == String(localized: .leftCell))
    }
}
