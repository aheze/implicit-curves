//
//  Point.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct Point: Equatable {
    var x: Double
    var y: Double
}

// a point with the function value at the point
struct ValuedPoint {
    var point: Point
    var value: Double

    static func midpoint(p1: ValuedPoint, p2: ValuedPoint, function: (Point) -> Double) -> ValuedPoint {
        let midpointX = (p1.point.x + p2.point.x) / 2
        let midpointY = (p1.point.y + p2.point.y) / 2
        let midpoint = Point(x: midpointX, y: midpointY)
        let valuedPoint = ValuedPoint(point: midpoint, value: function(midpoint))
        return valuedPoint
    }

    // Find the point on line p1--p2 with value 0
    // linear interpolation
    static func intersectZero(p1: ValuedPoint, p2: ValuedPoint, function: (Point) -> Double) -> ValuedPoint {
        // get difference between values
        let denominator = p1.value - p2.value

        // Calculate the "pull" for p1 and p2
        // if k1 is super small, then "pull" towards k2
        let k1 = -p2.value / denominator
        let k2 = p1.value / denominator

        // Apply weights
        let pointX = (k1 * p1.point.x) + (k2 * p2.point.x)
        let pointY = (k1 * p1.point.y) + (k2 * p2.point.y)

        let point = Point(x: pointX, y: pointY)
        let valuedPoint = ValuedPoint(point: point, value: function(point))
        return valuedPoint
    }
}

