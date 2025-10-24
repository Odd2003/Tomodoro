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

    // move dots higher by increasing this value
    private let dotsBottomPadding: CGFloat = 30

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $page) {
                DailyStatsScreen(vm: vm).tag(0)
                GenreStatsScreen(vm: vm).tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // hide system dots
            .ignoresSafeArea(.container, edges: .bottom) //
            .background(AppTheme.canvas.ignoresSafeArea())

            PageDots(count: 2, selected: page)
                .padding(.bottom, dotsBottomPadding)
                .allowsHitTesting(false)
        }
        .onAppear { vm.bind(to: store) }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(page == 0 ? "Statistics" : "Genres")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .tint(AppTheme.bar)
        .preferredColorScheme(.light)
    }
}

#Preview { NavigationStack { StatisticsTabView() } }

private struct PageDots: View {
    let count: Int
    let selected: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(i == selected ? AppTheme.bar : Color.gray.opacity(0.35))
                    .frame(width: 8, height: 8)
                    .animation(.easeOut(duration: 0.2), value: selected)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
    }
}
