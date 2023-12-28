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
        self.next = other
        other.previous = self
    }
}

// a, b, c, d should be clockwise oriented, with center on the inside of that quad
func fourTriangles(
    a: ValuedPoint,
    b: ValuedPoint,
    c: ValuedPoint,
    d: ValuedPoint,
    center: ValuedPoint
) -> (Triangle, Triangle, Triangle, Triangle) {
    let triangles = (
        Triangle(vertices: [a, b, center]),
        Triangle(vertices: [b, c, center]),
        Triangle(vertices: [c, d, center]),
        Triangle(vertices: [d, a, center])
    )
    
    return triangles
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
    var hangingNext = [String: Triangle]()
    
    var root: Cell
    
    var function: (Point) -> Double
    
    init(triangles: [Triangle], hangingNext: [String : Triangle] = [String: Triangle](), root: Cell, function: @escaping (Point) -> Double) {
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
            triangulate(inside: quad)
        }
        
        
//        for child in quad.children:
//            self.triangulate_inside(child)
//        self.triangulate_crossing_row(quad.children[0], quad.children[1])
//        self.triangulate_crossing_row(quad.children[2], quad.children[3])
//        self.triangulate_crossing_col(quad.children[0], quad.children[2])
//        self.triangulate_crossing_col(quad.children[1], quad.children[3])

    }
}
