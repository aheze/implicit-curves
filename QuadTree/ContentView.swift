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
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")

            Color.clear
                .frame(width: viewModel.viewportSize.width, height: viewModel.viewportSize.height)
                .overlay {
                    ZStack(alignment: .topLeading) {
                        ForEach(viewModel.displayedCells) { displayedCell in
                            let color: Color = {
                                switch displayedCell.cell.depth {
                                case 0:
                                    return .red
                                case 1:
                                    return .orange
                                case 2:
                                    return .yellow
                                case 3:
                                    return .green
                                case 4:
                                    return .teal
                                case 5:
                                    return .blue
                                case 6:
                                    return .purple
                                case 7:
                                    return .pink
                                case 8:
                                    return .brown
                                default:
                                    return .black
                                }
                            }()

                            Rectangle()
                                .stroke(color, lineWidth: 1)
                                .frame(width: displayedCell.frame.width, height: displayedCell.frame.height)
                                .offset(x: displayedCell.frame.minX, y: displayedCell.frame.minY)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .drawingGroup()
                .opacity(0.1)
                .overlay {
                    chart
                }
                .border(Color.blue.gradient.opacity(0.5), width: 2)
        }
        .padding()
    }

    var chart: some View {
        Chart {
            ForEach(viewModel.graphCurves) { graphCurve in
                ForEach(graphCurve.points, id: \.x) { point in
                    PointMark(x: .value("x", point.x), y: .value("y", point.y))
                        .foregroundStyle(Color.black)
                        .symbolSize(0.5)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
