//
//  ContentView.swift
//  QuadTree
//  
//  Created by Andrew Zheng (github.com/aheze) on 12/27/23.
//  Copyright © 2023 Andrew Zheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Color.yellow
                .frame(width: 400, height: 300)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
