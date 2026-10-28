//
//  MenuViewTests.swift
//  ShapeDuelTests
//
//  Created by Churkin Vitaly on 28.10.2026.
//

import Testing
import UIKit
@testable import ShapeDuel

struct MenuViewTests {

    /// On the largest text size the menu does not fit the screen and its content moves when scrolled
    @Test func contentScrollsOnLargestTextSize() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        let menuView = MenuView()
        let viewController = UIViewController()
        viewController.view = menuView
        window.rootViewController = NavigationController(rootViewController: viewController)
        window.isHidden = false
        menuView.showItems([
            MenuItemViewModel(mode: .computer, title: "Против компьютера", subtitle: "Три уровня сложности"),
            MenuItemViewModel(mode: .twoPlayers, title: "Вдвоём", subtitle: "На одном телефоне")
        ])
        window.layoutIfNeeded()
        let scrollView = try #require(menuView.subviews.compactMap { $0 as? UIScrollView }.first)
        let item = try #require(allSubviews(of: menuView).first { $0 is MenuItemView })
        let contentHeight = scrollView.contentSize.height
        let itemY = item.convert(item.bounds, to: window).minY

        scrollView.contentOffset.y = 100
        window.layoutIfNeeded()

        #expect(contentHeight > scrollView.bounds.height)
        #expect(scrollView.contentSize.height == contentHeight)
        #expect(abs(item.convert(item.bounds, to: window).minY - (itemY - 100)) < 0.5)
    }

    /// Back from the largest text size the items take their usual height and do not stretch
    @Test func itemsDoNotStretchWhenTextGetsSmaller() throws {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        window.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        let menuView = MenuView()
        let viewController = UIViewController()
        viewController.view = menuView
        window.rootViewController = NavigationController(rootViewController: viewController)
        window.isHidden = false
        menuView.showItems([
            MenuItemViewModel(mode: .computer, title: "Против компьютера", subtitle: "Три уровня сложности"),
            MenuItemViewModel(mode: .twoPlayers, title: "Вдвоём", subtitle: "На одном телефоне")
        ])
        window.layoutIfNeeded()

        window.traitOverrides.preferredContentSizeCategory = .large
        window.layoutIfNeeded()

        let heights = allSubviews(of: menuView).filter { $0 is MenuItemView }.map(\.bounds.height)
        #expect(heights == [Size.menuItemHeight, Size.menuItemHeight])
    }
}

extension MenuViewTests {

    // MARK: - Private methods

    private func allSubviews(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + allSubviews(of: $0) }
    }
}
