//
//  Song.swift
//  Tomodoro
//
//  Created by Rosario d'Antonio on 21/10/25.
//

import Foundation
import SwiftUI
enum Genre: String, CaseIterable {
    
    case lofiGenre = "Lo-Fi"
    case popGenre = "Pop"
    case rockGenre = "Rock"
    case whiteNoise = "White Noise"
    
}

class Song: Identifiable {

    var id: UUID = UUID()
    
    var name: String
    var genre: Genre
    var favourite: Bool
    
    init(name: String, genre: Genre, favourite: Bool) {
        self.name = name
        self.genre = genre
        self.favourite = favourite
    }
}

class SongList {

    var songs: [Song]
    
    init() {
        songs = [
            
            Song(name: "Good Night", genre: Genre.lofiGenre, favourite: false),
            Song(name: "Cute Japan", genre: Genre.lofiGenre, favourite: false),
            Song(name: "Gentle Rain", genre: Genre.whiteNoise, favourite: false),
            Song(name: "December Rain", genre: Genre.lofiGenre, favourite: false),
            Song(name: "Fun Pop", genre: Genre.popGenre, favourite: false),
            Song(name: "TavC City Stroll", genre: Genre.popGenre, favourite: false),
            Song(name: "Upbeat Cher", genre: Genre.popGenre, favourite: false),
        ]
    }
    
}

