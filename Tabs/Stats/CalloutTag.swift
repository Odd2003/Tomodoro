//
//  CalloutTag.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 24/10/25.
//

import Foundation
import SwiftUI

struct CalloutTag: View {
    var text: String
    var textColor: Color = .primary
    var baseOpacity: Double = 0.95

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    Capsule().fill(Color(.systemBackground).opacity(baseOpacity))
                    Capsule().fill(.ultraThinMaterial)
                }
            )
            .foregroundColor(textColor)
            .compositingGroup()
            .shadow(color: .black.opacity(0.12), radius: 2, y: 1)
            .zIndex(1)
    }
}
