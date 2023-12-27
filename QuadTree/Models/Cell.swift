//
//  Cell.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import SwiftUI

func verticesFromExtremes(
    minX: Double,
    maxX: Double,
    minY: Double,
    maxY: Double,
    function: (Point) -> Double
) -> Frame {
    let bLPoint = Point(x: minX, y: minY)
    let bRPoint = Point(x: maxX, y: minY)
    let tLPoint = Point(x: minX, y: maxY)
    let tRPoint = Point(x: maxX, y: maxY)

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

            let minX = (frame.bL.point.x + vertex.point.x) / 2
            let maxX = (frame.tR.point.x + vertex.point.x) / 2
            let minY = (frame.bL.point.y + vertex.point.y) / 2
            let maxY = (frame.tR.point.y + vertex.point.y) / 2
            let frame = verticesFromExtremes(minX: minX, maxX: maxX, minY: minY, maxY: maxY, function: function)

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

}

// @dataclass
// class Cell(MinimalCell):
//    depth: int
//    # Children go in same order: bottom-left, bottom-right, top-left, top-right
//    children: list[Cell]
//    parent: Cell
//    child_direction: int
//
//    def compute_children(self, fn: Func) -> None:
//        assert self.children == []
//        for i, vertex in enumerate(self.vertices):
//            pmin = (self.vertices[0].pos + vertex.pos) / 2
//            pmax = (self.vertices[-1].pos + vertex.pos) / 2
//            vertices = vertices_from_extremes(self.dim, pmin, pmax, fn)
//            new_quad = Cell(self.dim, vertices, self.depth + 1, [], self, i)
//            self.children.append(new_quad)

// @dataclass
// class MinimalCell:
//    dim: int
//    # In 2 dimensions, vertices = [bottom-left, bottom-right, top-left, top-right] points
//    vertices: list[ValuedPoint]
//
//    def get_subcell(self, axis: int, dir: int) -> MinimalCell:
//        """Given an n-cell, this returns an (n-1)-cell (with half the vertices)"""
//        m = 1 << axis
//        return MinimalCell(self.dim - 1, [v for i, v in enumerate(self.vertices) if (i & m > 0) == dir])
//
//    def get_dual(self, fn: Func) -> ValuedPoint:
//        return ValuedPoint.midpoint(self.vertices[0], self.vertices[-1], fn)

/*
    axis: 0 = x, 1 = y
    direction: 0 = negative, 1 = positive

    Example: getSubcell(axis: 0, direction: 1)
        returns the cells on the tR and bR

    Example: getSubcell(axis: 1, direction: 1)
        returns the cells on the tL and tR
 */
// func getSubcell(axis: Int, direction: Int) {}
