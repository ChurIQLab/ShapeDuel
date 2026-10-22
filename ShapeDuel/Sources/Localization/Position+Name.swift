//
//  Position+Name.swift
//  ShapeDuel
//
//  Created by Churkin Vitaly on 22.10.2026.
//

import Foundation

extension Position {
    /// The place of the cell on the 3×3 board, such as «Top left»; on another size — the row and the column
    var accessibilityName: String {
        guard Board.size == Constants.namedBoardSize else { return rowColumnName }
        switch (row, column) {
        case (0, 0): return String(localized: .topLeftCell)
        case (0, 1): return String(localized: .topCell)
        case (0, 2): return String(localized: .topRightCell)
        case (1, 0): return String(localized: .leftCell)
        case (1, 1): return String(localized: .centerCell)
        case (1, 2): return String(localized: .rightCell)
        case (2, 0): return String(localized: .bottomLeftCell)
        case (2, 1): return String(localized: .bottomCell)
        case (2, 2): return String(localized: .bottomRightCell)
        default: return rowColumnName
        }
    }

    private var rowColumnName: String {
        String(localized: .cellRowColumn(row + 1, column + 1))
    }
}

// MARK: - Constants

extension Position {
    struct Constants {
        /// The board size the cell names are written for
        static let namedBoardSize = 3
    }
}
