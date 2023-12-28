//
//  Rendering.swift
//  QuadTree
//  
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct DisplayedCell: Identifiable {
    var id = UUID()
    var cell: Cell
    var frame: CGRect
}

extension Cell {
    public func levelOrderTraversal(visit: (Cell) -> Void) {
        visit(self)
        var queue = [Cell]()
        children.forEach { queue.append($0) }
        
        while !queue.isEmpty {
            let node = queue.removeFirst()
            visit(node)
            node.children.forEach { queue.append($0) }
        }
    }
}
