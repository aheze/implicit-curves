//
//  Cell.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import Collections
import SwiftUI

func verticesFromExtremes(
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

struct Frame {
    var bL: ValuedPoint
    var bR: ValuedPoint
    var tL: ValuedPoint
    var tR: ValuedPoint

    // In 2 dimensions, vertices = [bottom-left, bottom-right, top-left, top-right] points
    var vertices: [ValuedPoint] {
        [self.bL, self.bR, self.tL, self.tR]
    }
}

class Cell {
    var frame: Frame
    var depth: Int
    var children: [Cell]
    var parent: Cell?

    // 0, 1, 2, or 3
    // 4 corners
    var childDirection: Int

    init(frame: Frame, depth: Int, children: [Cell], parent: Cell?, childDirection: Int) {
        self.frame = frame
        self.depth = depth
        self.children = children
        self.parent = parent
        self.childDirection = childDirection
    }

    func computeChildren(function: (Point) -> Double) {
        guard self.children.isEmpty else {
            fatalError("Already has children")
        }

        let vertices = self.frame.vertices
        for index in vertices.indices {
            let vertex = vertices[index]

            let xMin = (frame.bL.point.x + vertex.point.x) / 2
            let xMax = (frame.tR.point.x + vertex.point.x) / 2
            let yMin = (frame.bL.point.y + vertex.point.y) / 2
            let yMax = (frame.tR.point.y + vertex.point.y) / 2
            let frame = verticesFromExtremes(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, function: function)

            let newQuad = Cell(frame: frame, depth: depth + 1, children: [], parent: self, childDirection: index)
            self.children.append(newQuad)
        }
    }

    func getLeavesInDirection(axis: Int, direction: Int) -> AnyIterator<Cell> {
        return AnyIterator {
            if !self.children.isEmpty {
                // 01 (1) for x axis (horizontal)
                // 10 (2) for y axis (vertical)
                let mask = 1 << axis

                // 2 dimensions
                // 00 (0)
                // 01 (1)
                // 10 (2)
                // 11 (3)
                for index in 0 ..< 4 {
                    // (index & mask) possible values and their meanings:
                    // For x axis (mask = 01):       For y axis (mask = 10):
                    // 00 & 01 = 00 (0)              00 & 10 = 00 (0)         -> bL
                    // 01 & 01 = 01 (1)              01 & 10 = 00 (0)         -> bR
                    // 10 & 01 = 00 (0)              10 & 10 = 10 (2)         -> tL
                    // 11 & 01 = 01 (1)              11 & 10 = 10 (2)         -> tR

                    // For the x-axis, children with an index of 1 or 3 (binary 01 or 11) will satisfy ((index & mask) > 0).
                    // For the y-axis, children with an index of 2 or 3 (binary 10 or 11) will satisfy this condition.
                    // The comparison ((index & mask) > 0) == (direction > 0) ensures that only children on the specified direction are considered.
                    // If direction is 0, it targets the negative direction (left or bottom),
                    // and if direction is 1, it targets the positive direction (right or top).
                    if ((index & mask) > 0) == (direction > 0) {
                        let leaves = self.children[index].getLeavesInDirection(axis: axis, direction: direction)
                        for leaf in leaves {
                            return leaf
                        }
                    }
                }

                return nil
            } else {
                return self
            }
        }
    }

    // Same arguments as get_leaves_in_direction.
    // Returns the quad (with depth <= self.depth) that shares a (dim-1)-cell
    // with self, where that (dim-1)-cell is the side of self defined by
    // axis and dir.
    func walkInDirection(axis: Int, direction: Int) -> Cell? {
        // 01 (1) for x axis (horizontal)
        // 10 (2) for y axis (vertical)
        let mask = 1 << axis

        // childDirection possible values:
        // 00 (0) bL
        // 01 (1) bR
        // 10 (2) tL
        // 11 (3) tR

        // (childDirection & mask) returns true if on the positive side
        if ((self.childDirection & mask) > 0) == (direction > 0) {
            // on the right side of the parent cell and moving right (or analogous)
            // so need to go up through the parent's parent

            if let parent {
                let parentWalked = parent.walkInDirection(axis: axis, direction: direction)

                if let parentWalked, !parentWalked.children.isEmpty {
                    // end at same depth, in the adjacent cell
                    // from a to b
                    //
                    // +---+---+ +---+---+
                    // |   |   | |   |   |
                    // +---+---+ +---+---+
                    // |   | a | | b |   |
                    // +---+---+ +---+---+
                    //

                    // If you are moving along the x-axis and childDirection is 01 (bottom-right),
                    // XOR with 01 (x-axis mask) changes it to 00 (bottom-left).
                    //
                    // If moving along the y-axis and childDirection is 10 (top-left),
                    // XOR with 10 (y-axis mask) changes it to 00 (bottom-left).
                    return parentWalked.children[self.childDirection ^ mask]
                } else {
                    // end at lesser depth (bigger quad)
                    return parentWalked
                }
            } else {
                return nil
            }
        } else {
            // try to get a sibling cell
            if let parent {
                return parent.children[self.childDirection ^ mask]
            } else {
                return nil
            }
        }
    }
}

func shouldDescendDeepCell(cell: Cell, tolerance: Double) -> Bool {
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
            if valuedPoint.value != cell.frame.bL.value {
                return true
            }
        }

        return false
    }
}

func buildTree(
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

    let frame = verticesFromExtremes(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, function: function)

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

// def build_tree(
//    dim: int,
//    fn: Func,
//    pmin: Point,
//    pmax: Point,
//    min_depth: int,
//    max_cells: int,
//    tol: np.ndarray,
// ) -> Cell:
//    branching_factor = 1 << dim
//    # min_depth takes precedence over max_quads
//    max_cells = max(branching_factor ** min_depth, max_cells)
//    vertices = vertices_from_extremes(dim, pmin, pmax, fn)
//
//    # root's childDirection is 0, even though none is reasonable
//    current_quad = root = Cell(dim, vertices, 0, [], None, 0)
//    quad_queue = deque([root])
//    leaf_count = 1
//
//    while len(quad_queue) > 0 and leaf_count < max_cells:
//        current_quad = quad_queue.popleft()
//        if current_quad.depth < min_depth or should_descend_deep_cell(
//            current_quad, tol
//        ):
//            current_quad.compute_children(fn)
//            quad_queue.extend(current_quad.children)
//            # add 4 for the new quads, subtract 1 for the old quad not being a leaf anymore
//            leaf_count += branching_factor - 1
//    return root

//
//
//// unused
//// func walkLeavesInDirection(axis: Int, direction: Int) -> AnyIterator<Cell> {
////    let walked = self.walkInDirection(axis: axis, direction: direction)
////
////    return AnyIterator {
////        if let walked {
////            let leaves = walked.getLeavesInDirection(axis: axis, direction: direction)
////            for leaf in leaves {
////                return leaf
////            }
////            return nil
////        } else {
////            return nil
////        }
////    }
//// }
