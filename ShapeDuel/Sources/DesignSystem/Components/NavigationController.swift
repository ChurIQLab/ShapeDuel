//
//  NavigationController.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 25.09.2026.
//

import UIKit

/// System navigation bar on every screen: transparent, rounded title, back button without text
final class NavigationController: UINavigationController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        registerForTraitChanges(
            [UITraitPreferredContentSizeCategory.self]
        ) { (navigationController: NavigationController, _: UITraitCollection) in
            navigationController.setupNavigationBar()
        }
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        viewControllers.forEach(hideBackButtonTitle)
        super.setViewControllers(viewControllers, animated: animated)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        hideBackButtonTitle(of: viewController)
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - Setups

    /// The title grows with the text size up to xxxL, like on the segmented controls: the bar keeps its height
    private func setupNavigationBar() {
        navigationBar.maximumContentSizeCategory = Constants.maximumContentSizeCategory
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .font: Typography.accent.font(compatibleWith: navigationBar.traitCollection),
            .foregroundColor: UIColor.primaryText
        ]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = .primaryText
    }

    // MARK: - Private methods

    private func hideBackButtonTitle(of viewController: UIViewController) {
        viewController.navigationItem.backButtonDisplayMode = .minimal
    }
}

// MARK: - Constants

extension NavigationController {
    struct Constants {
        static let maximumContentSizeCategory: UIContentSizeCategory = .extraExtraExtraLarge
    }
}
