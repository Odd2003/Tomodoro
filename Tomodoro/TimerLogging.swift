//
//  TimerLogging.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 24/10/25.
//

import Foundation

extension AppStatsStore {
    /// Log a finished focus session. If you only know the duration, we’ll construct start/end.
    @MainActor
    func logCompletedSession(durationSeconds: Int, genre: String, endedAt: Date = Date()) {
        let end = endedAt
        let start = end.addingTimeInterval(TimeInterval(-durationSeconds))
        let session = StudySession(start: start, end: end, genre: genre, completed: true)
        add(session) // persists + publishes; Stats screens update automatically
    }
}
