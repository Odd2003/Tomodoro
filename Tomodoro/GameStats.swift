//
//  GameStats.swift
//  Tomodoro
//
//  Created by Rosario d'Antonio on 18/10/25.
//

import Foundation
import SwiftData

@Model
class GameStats {
    var characterCount: Int
    var goldCharCount: Int
    
    init(characterCount: Int = 0, goldCharCount: Int = 0) {
        self.characterCount = characterCount
        self.goldCharCount = goldCharCount
    }
    
}
