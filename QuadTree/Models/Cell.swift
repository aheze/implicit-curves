//
//  Cell.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import Foundation

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
            let frame = Global.frameFromCorners(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, function: function)

            let newQuad = Cell(frame: frame, depth: depth + 1, children: [], parent: self, childDirection: index)
            self.children.append(newQuad)
        }
    }
}
