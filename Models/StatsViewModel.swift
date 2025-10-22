//
//  StatsViewModel.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

import Foundation
import Combine

// MARK: - View data structs

struct DailyTotal: Identifiable, Hashable {
    var id: Date { day }
    let day: Date
    let totalMinutes: Int
}

struct GenreTotal: Identifiable, Hashable {
    var id: String { genre }
    let genre: String
    let totalMinutes: Int
}

// MARK: - ViewModel

@MainActor
final class StatsViewModel: ObservableObject {
    @Published var sessions: [StudySession] = []

    // Hook the VM to the store (called from StatisticsTabView.onAppear)
    func bind(to store: AppStatsStore) {
        self.sessions = store.sessions
        store.$sessions
            .receive(on: RunLoop.main)
            .assign(to: &self.$sessions)
    }

    // ---------- Aggregations (all-time) ----------

    var dailyTotals: [DailyTotal] {
        let grouped = Dictionary(grouping: sessions.filter { $0.completed }) { $0.dayStart }
        return grouped
            .map { .init(day: $0.key, totalMinutes: $0.value.reduce(0) { $0 + $1.minutes }) }
            .sorted { $0.day < $1.day }
    }

    var genreTotals: [GenreTotal] {
        let grouped = Dictionary(grouping: sessions.filter { $0.completed }) { $0.genre }
        return grouped
            .map { .init(genre: $0.key, totalMinutes: $0.value.reduce(0) { $0 + $1.minutes }) }
            .sorted { $0.totalMinutes > $1.totalMinutes }
    }

    var sessionsGroupedByDay: [(day: Date, items: [StudySession])] {
        let grouped = Dictionary(grouping: sessions) { $0.dayStart }
        return grouped
            .map { ($0.key, $0.value.sorted { $0.start < $1.start }) }
            .sorted { $0.0 > $1.0 }
    }

    var genresWithMinutes: [(genre: String, minutes: Int)] {
        genreTotals.map { ($0.genre, $0.totalMinutes) }
    }

    // ---------- Rolling last 7 days (today included) ----------

    /// Exact 7 day anchors (oldest → newest) in device timezone.
    var last7Days: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // 0..6 reversed gives oldest first
        return (0..<7).reversed().compactMap { off in
            cal.date(byAdding: .day, value: -off, to: today)
        }
    }

    /// Exactly 7 items; zeros for days with no completed sessions.
    var dailyTotalsLast7: [DailyTotal] {
        let completed = sessions.filter { $0.completed }
        let grouped = Dictionary(grouping: completed) { $0.dayStart }

        return last7Days.map { day in
            let total = (grouped[day] ?? []).reduce(0) { $0 + $1.minutes }
            return DailyTotal(day: day, totalMinutes: total)
        }
    }
}
