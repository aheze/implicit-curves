//
//  Global.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import Collections
import Foundation
import simd // for sign

enum Global {}

// MARK: - Frame

extension Global {
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
                    sign(valuedPoint.value - p1.value) == sign(p2.value - valuedPoint.value)
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

// MARK: - Cell

extension Global {
    static func buildTree(
        function: (Point) -> Double,
        xMin: Double,
        xMax: Double,
        yMin: Double,
        yMax: Double,
        minDepth: Int,
        maxCells: Int,
        tolerance: Double
    ) -> Cell {
        // 4 branches
        let branchingFactor = 4

        let maxCellFromMinDepth = Int(pow(Double(branchingFactor), Double(minDepth)))

        // min_depth takes precedence over max_quads
        let maxCells = max(maxCellFromMinDepth, maxCells)

        let frame = Global.frameFromCorners(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, function: function)

        // root's childDirection is 0, even though none is reasonable
        let root = Cell(frame: frame, depth: 0, children: [], parent: nil, childDirection: 0)

        var quadQueue: Deque = [root]
        var leafCount = 1

        while !quadQueue.isEmpty && leafCount < maxCells {
            guard let currentQuad = quadQueue.popFirst() else {
                print("No current quad?")
                break
            }

            if currentQuad.depth < minDepth || shouldDescendDeepCell(cell: currentQuad, tolerance: tolerance) {
                currentQuad.computeChildren(function: function)
                quadQueue.append(contentsOf: currentQuad.children)

                // add 4 for the new quads, subtract 1 for the old quad not being a leaf anymore
                leafCount += branchingFactor - 1
            }
        }

        return root
    }

    static func shouldDescendDeepCell(cell: Cell, tolerance: Double) -> Bool {
        let distanceX = cell.frame.tR.point.x - cell.frame.bL.point.x
        let distanceY = cell.frame.tR.point.y - cell.frame.bL.point.y

        let adjustedTolerance = 10 * tolerance
        if distanceX < adjustedTolerance && distanceY < adjustedTolerance {
            // Too small of a cell to be worth descending
            // We compare to 10*tol instead of tol because the simplices are smaller than the quads
            // The factor 10 itself is arbitrary.
            return false
        } else if cell.frame.vertices.allSatisfy({ $0.value.isNaN }) {
            // in a region where the function is undefined
            return false
        } else if cell.frame.vertices.contains(where: { $0.value.isNaN }) {
            // straddling defined and undefined
            
            return true
        } else {
            // simple approach: only descend if we cross the isoline
            // (check if at least one of the vertex values has a different sign)
            // TODO: This could very much be improved:
            // e.g. by incorporating gradient or second-derivative
            // tests, etc., to cancel descending in approximately linear regions
            for valuedPoint in cell.frame.vertices.dropFirst() {
                if sign(valuedPoint.value) != sign(cell.frame.bL.value) {
                    return true
                }
            }

            return false
        }
    }
}
