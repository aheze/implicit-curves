//
//  Unused.swift
//  QuadTree
//  
//  Created by Andrew Zheng (github.com/aheze) on 12/28/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import Foundation

// Unused functions, for 3D isosurfaces
extension Cell {
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
