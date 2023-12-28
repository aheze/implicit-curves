//
//  ContentView.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import Charts
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack {

            Color.clear
                .frame(width: viewModel.viewportSize.width, height: viewModel.viewportSize.height)
                .overlay {
                    chart
                }
        }
        .padding()
        .navigationTitle("Quadtree")
    }

    var chart: some View {
        Chart {
            ForEach(viewModel.graphCurves) { graphCurve in
                ForEach(graphCurve.points, id: \.x) { point in
                    LineMark(x: .value("x", point.x), y: .value("y", point.y), series: .value("Series", "\(graphCurve.id.uuidString)"))
                        .foregroundStyle(Color.blue)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
