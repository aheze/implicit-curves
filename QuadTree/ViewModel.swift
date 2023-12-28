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

    @Published var viewportSize = CGSize(width: 500, height: 500)
    let xDomain = Double(-10) ... Double(10)
    let yDomain = Double(-10) ... Double(10)
    var domainWidth: Double { xDomain.upperBound - xDomain.lowerBound }
    var domainHeight: Double { yDomain.upperBound - yDomain.lowerBound }

    // function to render
    func function(point: Point) -> Double {
        let x = point.x
        let y = point.y

//        return y * pow(x - y, 2) - (4 * x) - 8
//        return pow(x, 2) + pow(y, 2) - 5
        return tan(pow(x, 2) + pow(y, 2)) - 1
    }

    // MARK: - Rendering

    @Published var displayedCells = [DisplayedCell]()
    @Published var graphCurves = [GraphCurve]()

    init() {
        let timer = TimeElapsed()

        let curves = Global.plotIsoline(
            function: function,
            xMin: xDomain.lowerBound,
            xMax: xDomain.upperBound,
            yMin: yDomain.lowerBound,
            yMax: yDomain.upperBound
        )

        print("curves: \(curves.count), \(timer)")

        let graphCurves = curves.map { points in
            GraphCurve(points: points)
        }

        self.graphCurves = graphCurves
    }
}
