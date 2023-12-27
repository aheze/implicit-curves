//
//  Cell.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import SwiftUI



// def vertices_from_extremes(dim: int, pmin: Point, pmax: Point, fn: Func) -> list[ValuedPoint]:
//    """Requires pmin.x ≤ pmax.x, pmin.y ≤ pmax.y"""
//    w = pmax - pmin
//    return [
//        ValuedPoint(np.array([pmin[d] + (i >> d & 1) * w[d] for d in range(dim)])).calc(fn) for i in range(1 << dim)
//    ]

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
        [bL, bR, tL, tR]
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
        guard children.isEmpty else {
            fatalError("Already has children")
        }

        let vertices = frame.vertices
        for index in vertices.indices {
            let vertex = vertices[index]

            let minX = (frame.bL.point.x + vertex.point.x) / 2
            let maxX = (frame.tR.point.x + vertex.point.x) / 2
            let minY = (frame.bL.point.y + vertex.point.y) / 2
            let maxY = (frame.tR.point.y + vertex.point.y) / 2
            let frame = verticesFromExtremes(minX: minX, maxX: maxX, minY: minY, maxY: maxY, function: function)
            
            let newQuad = Cell(frame: frame, depth: depth + 1, children: [], parent: self, childDirection: index)
            children.append(newQuad)
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
//func getSubcell(axis: Int, direction: Int) {}
