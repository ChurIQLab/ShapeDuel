//
//  ContentSizeTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 28.10.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

/// Text on an open screen follows a new text size without building the screen again
struct ContentSizeTests {

    @Test func sectionLabelGrowsAndStaysUppercased() throws {
        let label = SectionLabel()
        setContentSize(.large, on: label)
        label.text = "Difficulty"
        let defaultSize = try fontSize(of: label.attributedText)

        setLargestContentSize(on: label)

        #expect(try fontSize(of: label.attributedText) > defaultSize)
        #expect(label.text == "DIFFICULTY")
    }

    @Test func statusTextGrows() throws {
        let statusView = GameStatusView()
        setContentSize(.large, on: statusView)
        statusView.configure(with: GameStatusViewModel(side: .first, figure: .cross, name: "Anna") { "Turn: \($0)" })
        let label = try #require(labels(in: statusView).first)
        let defaultSize = try fontSize(of: label.attributedText)

        setLargestContentSize(on: statusView)

        #expect(try fontSize(of: label.attributedText) > defaultSize)
    }

    @Test func capsuleButtonTitleGrows() throws {
        let button = CapsuleButton(title: "Play", style: .primary)
        setContentSize(.large, on: button)
        button.layoutIfNeeded()
        let defaultSize = try #require(button.titleLabel?.font.pointSize)

        setLargestContentSize(on: button)
        button.layoutIfNeeded()

        #expect(try #require(button.titleLabel?.font.pointSize) > defaultSize)
    }

    @Test func playerCardTextGrows() throws {
        let card = PlayerCardView()
        setContentSize(.large, on: card)
        card.configure(with: PlayerCardViewModel(side: .first, figure: .cross, name: "Anna", score: 1, state: .active))
        let defaultSizes = labels(in: card).map(\.font.pointSize)

        setLargestContentSize(on: card)

        let sizes = labels(in: card).map(\.font.pointSize)
        #expect(sizes.count == 2)
        #expect(zip(sizes, defaultSizes).allSatisfy { $0 > $1 })
    }

    @Test func segmentTitlesStopGrowingAtExtraExtraExtraLarge() throws {
        let control = SegmentedControl(titles: ["Easy", "Medium", "Hard"])
        let cappedSize = Typography.captionBold.font(
            compatibleWith: UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge)
        ).pointSize
        // The text size comes from the screen, as in the app: an override on the control itself is not limited
        let screen = UIView()
        screen.addSubview(control)

        setLargestContentSize(on: screen)

        let sizes = labels(in: control).map(\.font.pointSize)
        #expect(sizes.count == 3)
        #expect(sizes.allSatisfy { $0 == cappedSize })
    }

    @Test func capsuleButtonGrowsTallerThanMinimumHeight() {
        // The button updates its configuration only in a window
        let screen = UIWindow(frame: CGRect(x: 0, y: 0, width: 360, height: 800))
        screen.isHidden = false
        let button = CapsuleButton(title: "Play again", style: .primary, minimumHeight: 54)
        button.translatesAutoresizingMaskIntoConstraints = false
        screen.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: screen.topAnchor),
            button.leadingAnchor.constraint(equalTo: screen.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: screen.trailingAnchor)
        ])
        setContentSize(.large, on: screen)
        screen.layoutIfNeeded()
        let defaultHeight = button.frame.height

        setLargestContentSize(on: screen)
        screen.layoutIfNeeded()

        #expect(defaultHeight == 54)
        #expect(button.frame.height > 54)
    }

    @Test func playerCardsGoOneUnderAnotherOnAccessibilitySizes() throws {
        let view = GameView()
        setContentSize(.large, on: view)
        let playersStackView = try #require(allSubviews(of: view).compactMap { $0 as? UIStackView }.first {
            $0.arrangedSubviews.contains { $0 is PlayerCardView }
        })
        #expect(playersStackView.axis == .horizontal)

        setLargestContentSize(on: view)

        #expect(playersStackView.axis == .vertical)
    }

    @Test func menuItemHidesChevronOnAccessibilitySizes() throws {
        let item = MenuItemView()
        setContentSize(.large, on: item)
        let chevron = try #require(allSubviews(of: item).compactMap { $0 as? UIImageView }.last)
        #expect(!chevron.isHidden)

        setLargestContentSize(on: item)

        #expect(chevron.isHidden)
    }

    @Test func segmentsShowLargeContentViewer() {
        let control = SegmentedControl(titles: ["Easy", "Medium", "Hard"])

        let segments = allSubviews(of: control).filter(\.showsLargeContentViewer)

        #expect(segments.map(\.largeContentTitle) == ["Easy", "Medium", "Hard"])
        #expect(control.interactions.contains { $0 is UILargeContentViewerInteraction })
    }
}

extension ContentSizeTests {

    // MARK: - Private methods

    private func setLargestContentSize(on view: UIView) {
        setContentSize(.accessibilityExtraExtraExtraLarge, on: view)
    }

    /// Set first to the default size, so the test does not depend on the text size of the simulator
    private func setContentSize(_ category: UIContentSizeCategory, on view: UIView) {
        view.traitOverrides.preferredContentSizeCategory = category
        view.updateTraitsIfNeeded()
        allSubviews(of: view).forEach { $0.updateTraitsIfNeeded() }
    }

    private func fontSize(of text: NSAttributedString?) throws -> CGFloat {
        let text = try #require(text)
        let font = try #require(text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont)
        return font.pointSize
    }

    private func labels(in view: UIView) -> [UILabel] {
        allSubviews(of: view).compactMap { $0 as? UILabel }
    }

    private func allSubviews(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + allSubviews(of: $0) }
    }
}
