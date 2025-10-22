//
//  ContentView.swift
//  Tomodoro
//
//  Created by Daniyar Yegeubay on 16/10/25.
//

import SwiftUI

struct ContentView: View {
    @State var selection = 1

    var body: some View {
        TabView(selection: $selection) {
            Tab("Statistics", systemImage: "chart.xyaxis.line", value: 0) {
                EmptyView()
            }

            Tab("Home", systemImage: "house", value: 1) {
                HomeView()
            }

            Tab("PomoLand", systemImage: "mountain.2", value: 2) {
                PomoLandView()
            }
        }
    }
}

#Preview {
    ContentView()
}
