//
//  RootTabView.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

import SwiftUI

enum RootTab: Hashable {
    case statistics, home, pomoland
}

struct RootTabView: View {
    @State private var selection: RootTab = .statistics   // start on your tab for now

    var body: some View {
        TabView(selection: $selection) {

            NavigationStack {
                StatisticsTabView()  // ← your existing Statistics pager
            }
            .tabItem { Label("Statistics", systemImage: "chart.bar.fill") }
            .tag(RootTab.statistics)
            .tint(AppTheme.bar)
            .preferredColorScheme(.light)

            NavigationStack {
                HomePlaceholderView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(RootTab.home)

            NavigationStack {
                PomoLandPlaceholderView()
            }
            .tabItem { Label("PomoLand", systemImage: "mountain.2.fill") }
            .tag(RootTab.pomoland)
        }
        .tint(AppTheme.bar)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview { RootTabView() }
