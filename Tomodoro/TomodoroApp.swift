//
//  TomodoroApp.swift
//  Tomodoro
//
//  Created by Daniyar Yegeubay on 16/10/25.
//

import SwiftUI
import SwiftData

@main
struct TomodoroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .modelContainer(for: GameStats.self)
        }
    }
}
