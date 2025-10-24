//
//  StudySession.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

import Foundation

// StudySession.swift
struct StudySession: Identifiable, Codable, Hashable {
    let id: UUID
    let start: Date
    let end: Date
    let genre: String
    let completed: Bool

    init(id: UUID = UUID(), start: Date, end: Date, genre: String, completed: Bool = true) {
        self.id = id
        self.start = start
        self.end = end
        self.genre = genre
        self.completed = completed
    }

    // ⬇️ ceil to minutes and enforce minimum 1 minute
    var minutes: Int {
        let seconds = max(0, end.timeIntervalSince(start))
        return max(1, Int(ceil(seconds / 60.0)))
    }

    var dayStart: Date { Calendar.current.startOfDay(for: start) }
}
