//
//  ContentView.swift
//  Tomodoro
//
//  Created by Daniyar Yegeubay on 16/10/25.
//

import SwiftUI

struct ContentView: View {
    @State var selection = 1
    @State private var songPlayer = AudioService()

    // 👇 shared stats store (persisted)
    @StateObject private var store = AppStatsStore(preloadDemoData: true)

    var body: some View {
        TabView(selection: $selection) {
            Tab("Statistics", systemImage: "chart.bar.fill", value: 0) {
                StatisticsTabView()
            }

            Tab("Home", systemImage: "house", value: 1) {
                HomeView(songPlayer: songPlayer)         // ← keep your Home
            }

            Tab("PomoLand", systemImage: "mountain.2", value: 2) {
                PomoLandView()
            }
        }
        .tint(AppTheme.bar)
        .environmentObject(store)                        // 👈 inject globally
        .preferredColorScheme(.light)
    }
}

#Preview { ContentView() }
