//
//  Theme.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

import Foundation
import SwiftUI

struct AppTheme {
    static let canvas = Color(hex: "#DFD6CB")   // your beige
    static let bar    = Color(hex: "#FF8B65")   // new orange
    static let card   = Color.white
    static let textPrimary = Color.black
    static let textSecondary = Color(white: 0.35)
    static let divider = Color(white: 0.90)
}

// Hex → Color helper
extension Color {
    init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 8: (r,g,b,a) = ((int >> 24)&0xff,(int >> 16)&0xff,(int >> 8)&0xff,int & 0xff)
        case 6: (r,g,b,a) = ((int >> 16)&0xff,(int >> 8)&0xff,int & 0xff,255)
        default: (r,g,b,a) = (0,0,0,255)
        }
        self.init(.sRGB,
                  red:   Double(r)/255,
                  green: Double(g)/255,
                  blue:  Double(b)/255,
                  opacity: Double(a)/255)
    }
}
