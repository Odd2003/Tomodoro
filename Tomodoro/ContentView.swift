//
//  ContentView.swift
//  Tomodoro
//
//  Created by Daniyar Yegeubay on 16/10/25.
//

import SwiftUI

struct ContentView: View {
    @State var selection = 1
    @State var songPlayer = AudioService()

    var body: some View {
        TabView(selection: $selection) {
            Tab("Statistics", systemImage: "chart.bar.fill", value: 0) {
                StatisticsTabView()
            }

            Tab("Home", systemImage: "house", value: 1) {
                HomeView(songPlayer: songPlayer)
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
