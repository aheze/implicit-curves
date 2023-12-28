//
//  Global.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import SwiftUI

enum Global {
    // get frame of vertices from each corner
    static func frameFromCorners(
        xMin: Double,
        xMax: Double,
        yMin: Double,
        yMax: Double,
        function: (Point) -> Double
    ) -> Frame {
        let bLPoint = Point(x: xMin, y: yMin)
        let bRPoint = Point(x: xMax, y: yMin)
        let tLPoint = Point(x: xMin, y: yMax)
        let tRPoint = Point(x: xMax, y: yMax)

        let bL = ValuedPoint(point: bLPoint, value: function(bLPoint))
        let bR = ValuedPoint(point: bRPoint, value: function(bRPoint))
        let tL = ValuedPoint(point: tLPoint, value: function(tLPoint))
        let tR = ValuedPoint(point: tRPoint, value: function(tRPoint))

        let frame = Frame(bL: bL, bR: bR, tL: tL, tR: tR)
        return frame
    }

    static func binarySearchZero(
        p1: ValuedPoint,
        p2: ValuedPoint,
        function: (Point) -> Double,
        tolerance: Double
    ) -> (valuedPoint: ValuedPoint, isZero: Bool) {
        let distanceX = abs(p2.point.x - p1.point.x)
        let distanceY = abs(p2.point.y - p1.point.y)
        
        // Use isZero to make sure it's not an asymptote like at x=0 on f(x,y) = 1/(xy) - 1
        if distanceX < tolerance, distanceY < tolerance {
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
}
