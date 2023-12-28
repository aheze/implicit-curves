//
//  ContentView.swift
//  QuadTree
//
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

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
                                    return .orange
                                case 4:
                                    return .blue
                                case 5:
                                    return .indigo
                                case 6:
                                    return .purple
                                case 7:
                                    return .pink
                                case 8:
                                    return .teal
                                case 9:
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
                }
                .border(Color.black, width: 2)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
