//
//  SegmentedControlTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 26.09.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct SegmentedControlTests {

    @Test func segmentsAreButtonsNamedAfterTitles() throws {
        let control = SegmentedControl(titles: Constants.titles)

        let segments = try segments(of: control)

        #expect(segments.map(\.accessibilityLabel) == Constants.titles)
        #expect(segments.allSatisfy { $0.isAccessibilityElement && $0.accessibilityTraits.contains(.button) })
    }

    @Test func onlySelectedSegmentHasSelectedTrait() throws {
        let control = SegmentedControl(titles: Constants.titles, selectedIndex: 1)

        #expect(try selectedIndices(of: control) == [1])
    }

    @Test func tapSelectsSegmentAndSendsValueChanged() throws {
        let control = SegmentedControl(titles: Constants.titles)
        var changes = 0
        control.addAction(UIAction { _ in changes += 1 }, for: .valueChanged)

        try segments(of: control)[2].sendActions(for: .touchUpInside)

        #expect(control.selectedIndex == 2)
        #expect(try selectedIndices(of: control) == [2])
        #expect(changes == 1)
    }

    @Test func tapOnSelectedSegmentSendsNothing() throws {
        let control = SegmentedControl(titles: Constants.titles, selectedIndex: 1)
        var changes = 0
        control.addAction(UIAction { _ in changes += 1 }, for: .valueChanged)

        try segments(of: control)[1].sendActions(for: .touchUpInside)

        #expect(changes == 0)
    }

    @Test func reduceMotionMovesThumbWithoutAnimation() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        window.isHidden = false
        let control = SegmentedControl(titles: Constants.titles) { true }
        control.frame = CGRect(x: 0, y: 0, width: 300, height: 44)
        window.addSubview(control)
        window.layoutIfNeeded()

        control.setSelectedIndex(2, animated: true)

        #expect(allLayers(of: control).allSatisfy { $0.animationKeys() == nil })
    }

    @Test func thumbSlidesWithoutReduceMotion() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        window.isHidden = false
        let control = SegmentedControl(titles: Constants.titles) { false }
        control.frame = CGRect(x: 0, y: 0, width: 300, height: 44)
        window.addSubview(control)
        window.layoutIfNeeded()

        control.setSelectedIndex(2, animated: true)

        #expect(allLayers(of: control).contains { $0.animationKeys() != nil })
    }

    @Test func selectingInCodeSendsNothing() throws {
        let control = SegmentedControl(titles: Constants.titles)
        var changes = 0
        control.addAction(UIAction { _ in changes += 1 }, for: .valueChanged)

        control.setSelectedIndex(2, animated: false)

        #expect(control.selectedIndex == 2)
        #expect(try selectedIndices(of: control) == [2])
        #expect(changes == 0)
    }

    @Test(arguments: [-1, 3])
    func indexOutOfRangeIsIgnored(index: Int) {
        let control = SegmentedControl(titles: Constants.titles, selectedIndex: index)

        control.setSelectedIndex(index, animated: false)

        #expect(control.selectedIndex == 0)
    }

    @Test func onBackgroundStyleHasBackgroundHeight() {
        #expect(height(of: .onBackground) == Size.segmentedControlHeight)
    }

    @Test func inCardStyleHasCardHeight() {
        #expect(height(of: .inCard) == Size.segmentedControlHeightInCard)
    }
}

extension SegmentedControlTests {

    // MARK: - Private methods

    private func segments(of control: SegmentedControl) throws -> [UIControl] {
        let segments = try #require(control.accessibilityElements as? [UIControl])
        try #require(segments.count == Constants.titles.count)
        return segments
    }

    private func height(of style: SegmentedControl.Style) -> CGFloat {
        let control = SegmentedControl(titles: Constants.titles, style: style)
        return control.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }

    private func allLayers(of view: UIView) -> [CALayer] {
        [view.layer] + view.subviews.flatMap { allLayers(of: $0) }
    }

    private func selectedIndices(of control: SegmentedControl) throws -> [Int] {
        try segments(of: control).indices.filter { index in
            try segments(of: control)[index].accessibilityTraits.contains(.selected)
        }
    }
}

// MARK: - Constants

extension SegmentedControlTests {
    struct Constants {
        static let titles = ["Easy", "Medium", "Hard"]
    }
}
