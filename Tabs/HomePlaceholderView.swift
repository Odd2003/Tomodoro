//
//  HomePlaceholderView.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

import SwiftUI

struct HomePlaceholderView: View {
    var body: some View {
        ZStack {
            AppTheme.canvas.ignoresSafeArea()
            Text("Home (placeholder)")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Home")
    }
}

