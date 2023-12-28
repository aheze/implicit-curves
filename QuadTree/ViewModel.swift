//
//  ViewModel.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import SwiftUI

class ViewModel: ObservableObject {
    // MARK: - Configuration

    @Published var viewportSize = CGSize(width: 500, height: 300)
    let xDomain = Double(-5) ... Double(5)
    let yDomain = Double(-3) ... Double(3)
    var domainWidth: Double { xDomain.upperBound - xDomain.lowerBound }
    var domainHeight: Double { yDomain.upperBound - yDomain.lowerBound }

    // function to render
    func function(point: Point) -> Double {
        return pow(point.x, 2) + pow(point.y, 2) - 10
//        return tan(pow(point.x, 2) + pow(point.y, 2)) - 1
//        return 1
    }

    // MARK: - Rendering

    @Published var displayedCells = [DisplayedCell]()

    init() {
        let timer = TimeElapsed()

        let root = Global.buildTree(
            function: function,
            xMin: xDomain.lowerBound,
            xMax: xDomain.upperBound,
            yMin: yDomain.lowerBound,
            yMax: yDomain.upperBound,
            minDepth: 5,
            maxCells: 5000,
            tolerance: domainWidth / 1000
        )

        var displayedCells = [DisplayedCell]()
        root.levelOrderTraversal { cell in
            
            let frame = CGRect(
                x: cell.frame.bL.point.x,
                y: cell.frame.bL.point.y,
                width: cell.frame.bR.point.x - cell.frame.bL.point.x,
                height: cell.frame.tL.point.y - cell.frame.bL.point.y
            )

            // half of the viewport

            var adjustedFrame = CGRect(
                x: viewportSize.width / 2 + (frame.minX / domainWidth) * viewportSize.width,
                y: viewportSize.height / 2 + (frame.minY / domainHeight) * viewportSize.height,
                width: (frame.width / domainWidth) * viewportSize.width,
                height: (frame.height / domainHeight) * viewportSize.height
            )

            adjustedFrame.origin.y = viewportSize.height - adjustedFrame.origin.y
            adjustedFrame.origin.y -= adjustedFrame.height

            let displayedCell = DisplayedCell(cell: cell, frame: adjustedFrame)
            displayedCells.append(displayedCell)
        }

        print("root: \(root) \(displayedCells.count). \(timer)")

        self.displayedCells = displayedCells
    }
}
