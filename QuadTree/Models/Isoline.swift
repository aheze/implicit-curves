//
//  Isoline.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import Foundation

class Triangle {
    var vertices: [ValuedPoint]
    
    // The order of triangle "next" is such that, when walking along the isoline in the direction of next,
    // you keep positive function values on your right and negative function values on your left.
    var next: Triangle?
    var previous: Triangle?
    var visited = false
    
    init(vertices: [ValuedPoint], next: Triangle? = nil, previous: Triangle? = nil, visited: Bool = false) {
        self.vertices = vertices
        self.next = next
        self.previous = previous
        self.visited = visited
    }
    
    func setNext(other: Triangle) {
        next = other
        other.previous = self
    }
}

// While triangulating, also compute the isolines.
//
// Divides each quad into 8 triangles from the quad's center. This simplifies
// adjacencies between triangles for the general case of multiresolution quadtrees.
//
// Based on Manson, Josiah, and Scott Schaefer. "Isosurfaces
// over simplicial partitions of multiresolution grids." Computer Graphics Forum.
// Vol. 29. No. 2. Oxford, UK: Blackwell Publishing Ltd, 2010.
// (https://people.engr.tamu.edu/schaefer/research/iso_simplicial.pdf),
// but this does not currently implement placing dual vertices based on the gradient.
class Triangulator {
    var triangles: [Triangle]
    
    // ID to triangle
    var hangingNext = [Point: Triangle]()
    
    var root: Cell
    
    var function: (Point) -> Double
    
    init(triangles: [Triangle], hangingNext: [Point: Triangle] = [Point: Triangle](), root: Cell, function: @escaping (Point) -> Double) {
        self.triangles = triangles
        self.hangingNext = hangingNext
        self.root = root
        self.function = function
    }
    
    func triangulate() -> [Triangle] {
        triangulate(inside: root)
        return triangles
    }
    
    func triangulate(inside quad: Cell) {
        for child in quad.children {
            triangulate(inside: child)
        }
        
        // bL, bR
        triangulateCrossingRow(a: quad.children[0], b: quad.children[1])
        
        // tL, tR
        triangulateCrossingRow(a: quad.children[2], b: quad.children[3])
        
        // bL, tL
        triangulateCrossingColumn(a: quad.children[0], b: quad.children[2])
        
        // bR, tR
        triangulateCrossingColumn(a: quad.children[1], b: quad.children[3])
    }
    
    func triangulateCrossingRow(a: Cell, b: Cell) {
        // Quad b should be to the right (greater x values) than quad a
        
        if !a.children.isEmpty, !b.children.isEmpty {
            // bR cell | bL cell
            triangulateCrossingRow(a: a.children[1], b: b.children[0])
            
            // tR cell | tL cell
            triangulateCrossingRow(a: a.children[3], b: b.children[2])
        } else if !a.children.isEmpty {
            // bR cell | big cell to right
            triangulateCrossingRow(a: a.children[1], b: b)
            
            // tR cell | big cell to right
            triangulateCrossingRow(a: a.children[3], b: b)
        } else if !b.children.isEmpty {
            // big cell to left | bL cell
            triangulateCrossingRow(a: a, b: b.children[0])
            
            // big cell to left | tL cell
            triangulateCrossingRow(a: a, b: b.children[2])
        } else {
            // a and b are minimal 2-cells (need to have triangles in between)
            let faceDualA = getFaceDual(frame: a.frame)
            let faceDualB = getFaceDual(frame: b.frame)
            
            // Add the four triangles from the centers of a and b to the shared edge between them
            if a.depth < b.depth {
                // a is a big cell, b is small cell
                //
                // +---+---+---+---+
                // |       | b |   |
                // +   a   +---+---+
                // |       |   |   |
                // +---+---+---+---+
                //
                // add line segment a to midpoint of b's left edge
                // result has 2 triangles in each cell
                let edgeDual = getEdgeDual(p1: b.frame.tL, p2: b.frame.bL)
                
                // triangles arranged like a diamond
                let triangles = Global.fourTriangles(
                    a: b.frame.tL,
                    b: faceDualB,
                    c: b.frame.bL,
                    d: faceDualA,
                    center: edgeDual
                )
                
                addFourTriangles(triangles: triangles)
            } else {
                // a is a small cell, b is a big cell
                // OR: same depth, a and b are adjacent horizontally
                let edgeDual = getEdgeDual(p1: a.frame.tR, p2: b.frame.bR)
                
                // result of code for same depth
                // +---+---+---+---+
                // |     / | \     |
                // +   a   +   b   +
                // |     \ | /     |
                // +---+---+---+---+
                let triangles = Global.fourTriangles(
                    a: a.frame.tR,
                    b: faceDualB,
                    c: a.frame.bR,
                    d: faceDualA,
                    center: edgeDual
                )
                
                addFourTriangles(triangles: triangles)
            }
        }
    }
    
    // Mostly a copy-paste of triangulate_crossing_row. For n-dimensions,
    // want to pass a dir index into a shared triangulate_crossing_dir function instead
    func triangulateCrossingColumn(a: Cell, b: Cell) {
        if !a.children.isEmpty, !b.children.isEmpty {
            // tL cell | bL cell
            triangulateCrossingColumn(a: a.children[2], b: b.children[0])
            
            // tR cell | bT cell
            triangulateCrossingColumn(a: a.children[3], b: b.children[1])
        } else if !a.children.isEmpty {
            triangulateCrossingColumn(a: a.children[2], b: b)
            triangulateCrossingColumn(a: a.children[3], b: b)
        } else if !b.children.isEmpty {
            triangulateCrossingColumn(a: a, b: b.children[0])
            triangulateCrossingColumn(a: a, b: b.children[1])
        } else {
            // a and b are minimal 2-cells (need to have triangles in between)
            
            let faceDualA = getFaceDual(frame: a.frame)
            let faceDualB = getFaceDual(frame: b.frame)
            
            // Add the four triangles from the centers of a and b to the shared edge between them
            if a.depth < b.depth {
                // b is smaller
                let edgeDual = getEdgeDual(p1: b.frame.bL, p2: b.frame.bR)
                let triangles = Global.fourTriangles(
                    a: b.frame.bL,
                    b: faceDualB,
                    c: b.frame.bR,
                    d: faceDualA,
                    center: edgeDual
                )
                addFourTriangles(triangles: triangles)
            } else {
                let edgeDual = getEdgeDual(p1: b.frame.tL, p2: b.frame.tR)
                let triangles = Global.fourTriangles(
                    a: a.frame.tL,
                    b: faceDualB,
                    c: a.frame.tR,
                    d: faceDualA,
                    center: edgeDual
                )
                addFourTriangles(triangles: triangles)
            }
        }
    }

    func addFourTriangles(triangles: (Triangle, Triangle, Triangle, Triangle)) {
        nextSandwichTriangles(a: triangles.0, b: triangles.1, c: triangles.2)
        nextSandwichTriangles(a: triangles.1, b: triangles.2, c: triangles.3)
        nextSandwichTriangles(a: triangles.2, b: triangles.3, c: triangles.0)
        nextSandwichTriangles(a: triangles.3, b: triangles.0, c: triangles.1)
        self.triangles.append(triangles.0)
        self.triangles.append(triangles.1)
        self.triangles.append(triangles.2)
        self.triangles.append(triangles.3)
    }
    
    func nextSandwichTriangles(a: Triangle, b: Triangle, c: Triangle) {
        // Find the "next" triangle for the triangle b. See Triangle for a description of the curve orientation.
        // We assume the triangles are oriented such that they share common vertices
        // center←[2]≡b[2]≡c[2] and x←a[1]≡b[0], y←b[1]≡c[0]
        
        let center = b.vertices[2]
        let x = b.vertices[0]
        let y = b.vertices[1]
        
        // Simple connections: inside the same four triangles
        // (Group 0 with negatives)
        if center.value > 0, y.value <= 0 {
            b.setNext(other: c)
        }
        
        // (Group 0 with negatives)
        if x.value > 0, center.value <= 0 {
            b.setNext(other: a)
        }
        
        // More difficult connections: complete a hanging connection
        // or wait for another triangle to complete this
        // We index using (double) the midpoint of the hanging edge
        let doubleMidpointX = x.point.x + y.point.x
        let doubleMidpointY = x.point.y + y.point.y
        
        // use as a key
        let doubleMidpoint = Point(x: doubleMidpointX, y: doubleMidpointY)
        
        // (Group 0 with negatives)
        if y.value > 0, x.value <= 0 {
            if let matchingTriangle = hangingNext[doubleMidpoint] {
                b.setNext(other: matchingTriangle)
            } else {
                hangingNext[doubleMidpoint] = b
            }
        } else if y.value <= 0, x.value > 0 {
            if let matchingTriangle = hangingNext[doubleMidpoint] {
                matchingTriangle.setNext(other: b)
            } else {
                hangingNext[doubleMidpoint] = b
            }
        }
    }
}

extension Triangulator {
    // Returns the dual point on an edge p1--p2
    func getEdgeDual(p1: ValuedPoint, p2: ValuedPoint) -> ValuedPoint {
        if (p1.value > 0) != (p1.value > 0) {
            // The edge crosses the isoline, so take the midpoint
            return ValuedPoint.midpoint(p1: p1, p2: p2, function: function)
        }
        
        let dt = Double(0.01)
        
        // ∇f(p1) is the gradient (derivative) of the function at p1
        // We intersect the planes with normals <∇f(p1), -1> and <∇f(p2), -1>
        
        // move slightly from p1 to p2. df = ∆f, so ∆f/∆t = 100*df1 near p1
        let point1X = p1.point.x * (1 - dt) + p2.point.x * dt
        let point1Y = p1.point.y * (1 - dt) + p2.point.y * dt
        let point1 = Point(x: point1X, y: point1Y)
        let df1 = function(point1)
        
        // move slightly from p2 to p1. df = ∆f, so ∆f/∆t = -100*df2 near p2
        let point2X = p1.point.x * dt + p2.point.x * (1 - dt)
        let point2Y = p1.point.y * dt + p2.point.y * (1 - dt)
        let point2 = Point(x: point2X, y: point2Y)
        let df2 = function(point2)
     
        // (Group 0 with negatives)
        if (df1 > 0) == (df2 > 0) {
            // The function either increases → ← or ← →, so a lerp would shoot out of bounds
            // Take the midpoint
            return ValuedPoint.midpoint(p1: p1, p2: p2, function: function)
        } else {
            // Function increases → 0 → or ← 0 ←
            let v1 = ValuedPoint(point: p1.point, value: df1)
            let v2 = ValuedPoint(point: p2.point, value: df2)
            return ValuedPoint.intersectZero(p1: v1, p2: v2, function: function)
        }
    }
    
    func getFaceDual(frame: Frame) -> ValuedPoint {
        // TODO: proper face dual
        return ValuedPoint.midpoint(p1: frame.bL, p2: frame.tR, function: function)
    }
}
