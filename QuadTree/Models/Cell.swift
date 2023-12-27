//
//  Cell.swift
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


//def vertices_from_extremes(dim: int, pmin: Point, pmax: Point, fn: Func) -> list[ValuedPoint]:
//    """Requires pmin.x ≤ pmax.x, pmin.y ≤ pmax.y"""
//    w = pmax - pmin
//    return [
//        ValuedPoint(np.array([pmin[d] + (i >> d & 1) * w[d] for d in range(dim)])).calc(fn) for i in range(1 << dim)
//    ]

func verticesFromExtremes(minX: Double, maxX: Double, minY: Double, maxY: Double, function: (Point) -> Double) {
    
}

struct MinimalCell {
    
    // In 2 dimensions, vertices = [bottom-left, bottom-right, top-left, top-right] points
//    var vertices: [CGPoint]
    
    var bL: Point
    var bR: Point
    var tL: Point
    var tR: Point
    
    var vertices: [Point] {
        [bL, bR, tL, tR]
    }

    /*
        axis: 0 = x, 1 = y
        direction: 0 = negative, 1 = positive
     
        Example: getSubcell(axis: 0, direction: 1)
            returns the cells on the tR and bR
     
        Example: getSubcell(axis: 1, direction: 1)
            returns the cells on the tL and tR
     */
    func getSubcell(axis: Int, direction: Int) {
        
        
        
    }
}

class Cell {
    var minimalCell: MinimalCell
    var depth: Int
    var children: [Cell]
    var parent: Cell?
    var childDirection: Int
    
    init(minimalCell: MinimalCell, depth: Int, children: [Cell], parent: Cell?, childDirection: Int) {
        self.minimalCell = minimalCell
        self.depth = depth
        self.children = children
        self.parent = parent
        self.childDirection = childDirection
    }
    
    func computeChildren(function: (Point) -> Double) {
        guard children.isEmpty else {
            fatalError("Already has children")
        }
        
        let vertices = minimalCell.vertices
        for index in vertices.indices {
            let vertex = vertices[index]
            
            let minX = (minimalCell.bL.x + vertex.x) / 2
            let maxX = (minimalCell.tR.x + vertex.x) / 2
            let minY = (minimalCell.bL.y + vertex.y) / 2
            let maxY = (minimalCell.tR.y + vertex.y) / 2
        }
    }
}


//@dataclass
//class Cell(MinimalCell):
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


//@dataclass
//class MinimalCell:
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
