//
//  StudySession.swift
//  Tomodoro
//
//  Created by Parham Kharbasi on 18/10/25.
//

import Foundation

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
    
    var minutes: Int { max(0, Int(end.timeIntervalSince(start) / 60)) }
    var dayStart: Date { Calendar.current.startOfDay(for: start) }
}
