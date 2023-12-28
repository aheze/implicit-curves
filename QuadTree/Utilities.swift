//
//  Utilities.swift
//  QuadTree
//  
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import Foundation

class TimeElapsed: CustomStringConvertible {
    private let startTime: CFAbsoluteTime
    private var endTime: CFAbsoluteTime?

    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    var description: String {
        time
    }

    var time: String {
        let format = String(format: "%.5f", duration)
        let string = "[\(format)s]"
        return string
    }

    var duration: Double {
        let endTime = CFAbsoluteTimeGetCurrent()
        return endTime - startTime
    }
}
