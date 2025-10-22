//
//  StatisticsTabView.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

import SwiftUI

struct StatisticsTabView: View {
    @StateObject private var store = AppStatsStore(preloadDemoData: true)
    @StateObject private var vm = StatsViewModel()
    @State private var page = 0

    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()

            TabView(selection: $page) {
                DailyStatsScreen(vm: vm).tag(0)     // keep your existing names
                GenreStatsScreen(vm: vm).tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))   // swipe + dots
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .safeAreaPadding(.bottom, 64) // keeps content above dots/tab bar
            .tint(AppTheme.bar)
            }
        .onAppear { vm.bind(to: store) }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(page == 0 ? "Statistics" : "Genres")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview { NavigationStack { StatisticsTabView() } }
