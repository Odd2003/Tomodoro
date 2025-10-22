//
//  StatsStore.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

// Services/StatsStore.swift
import Foundation
import SwiftUI
import Combine

protocol StatsStore {
    var sessions: [StudySession] { get set }
    func add(_ session: StudySession)
}

@MainActor
final class AppStatsStore: ObservableObject, StatsStore {
    @AppStorage("stats.sessions.json") private var sessionsJSON: String = "[]"
    @Published var sessions: [StudySession] = []

    init(preloadDemoData: Bool = true) {
        load()
        if preloadDemoData && sessions.isEmpty {
            sessions = DemoData.make()
            save()
        }
    }

    func add(_ session: StudySession) {
        sessions.append(session)
        save()
    }

    private func load() {
        do {
            let data = Data(sessionsJSON.utf8)
            sessions = try JSONDecoder().decode([StudySession].self, from: data)
        } catch {
            sessions = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(sessions)
            sessionsJSON = String(data: data, encoding: .utf8) ?? "[]"
        } catch { }
    }
}

enum DemoData {
    static func make() -> [StudySession] {
        var arr: [StudySession] = []
        let cal = Calendar.current
        let genres = ["Lo-Fi", "White Noise", "Rock", "Ambient", "Classical"]
        let today = cal.startOfDay(for: .now)
        for i in 0..<10 {
            let day = cal.date(byAdding: .day, value: -i, to: today)!
            let count = Int.random(in: 1...3)
            for _ in 0..<count {
                let startMin = Int.random(in: 9*60...22*60)
                let len = [15,25,30,45,60].randomElement()!
                let start = cal.date(byAdding: .minute, value: startMin, to: day)!
                let end = cal.date(byAdding: .minute, value: len, to: start)!
                arr.append(.init(start: start, end: end, genre: genres.randomElement()!, completed: true))
            }
        }
        return arr
    }
}
