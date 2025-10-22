//
//  PomoLandPlaceholderView.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

import SwiftUI

struct PomoLandPlaceholderView: View {
    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()
            Text("PomoLand (placeholder)")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("PomoLand")
    }
}
