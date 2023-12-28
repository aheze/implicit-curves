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

func binarySearchZero(
    p1: ValuedPoint,
    p2: ValuedPoint,
    function: (Point) -> Double,
    tolerance: Double
) -> (valuedPoint: ValuedPoint, isZero: Bool) {
    let distanceX = abs(p2.point.x - p1.point.x)
    let distanceY = abs(p2.point.y - p1.point.y)
    
    // Use isZero to make sure it's not an asymptote like at x=0 on f(x,y) = 1/(xy) - 1
    if distanceX < tolerance && distanceY < tolerance {
        // Binary search stop condition: too small to matter
        let valuedPoint = ValuedPoint.intersectZero(p1: p1, p2: p2, function: function)
        
        let isZero: Bool = {
            if valuedPoint.value == 0 {
                return true
            }
            
            if
                // prevent ≈inf from registering as a zero
                abs(valuedPoint.value) < 1e200,
                (valuedPoint.value - p1.value).sign == (p2.value - valuedPoint.value).sign
            {
                return true
            }
            
            return false
        }()
        
        return (valuedPoint, isZero)
    } else {
        // binary search
        
        let midpoint = ValuedPoint.midpoint(p1: p1, p2: p2, function: function)
        if midpoint.value == 0 {
            return (midpoint, true)
            
        } else if (midpoint.value > 0) == (p1.value > 0) {
            // (Group "0" with negatives)
            
            return binarySearchZero(p1: midpoint, p2: p2, function: function, tolerance: tolerance)
        } else {
            // negatives
            return binarySearchZero(p1: p1, p2: midpoint, function: function, tolerance: tolerance)
        }
    }
}
