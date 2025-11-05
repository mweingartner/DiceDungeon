//
//  HighScore.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 11/5/25.
//

import Foundation

struct HighScore: Codable, Comparable {
    let initials: String
    let xp: Int
    let roomNumber: Int
    let date: Date
    
    init(initials: String, xp: Int, roomNumber: Int, date: Date = Date()) {
        self.initials = initials
        self.xp = xp
        self.roomNumber = roomNumber
        self.date = date
    }
    
    // Comparable conformance - sort by XP (highest first)
    static func < (lhs: HighScore, rhs: HighScore) -> Bool {
        return lhs.xp < rhs.xp
    }
}

class HighScoreManager {
    static let shared = HighScoreManager()
    
    private let maxScores = 10
    private let fileName = "highscores.json"
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    private init() {}
    
    // Load high scores from file
    func loadScores() -> [HighScore] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let scores = try JSONDecoder().decode([HighScore].self, from: data)
            return scores.sorted(by: >)  // Sort highest to lowest
        } catch {
            print("Error loading high scores: \(error)")
            return []
        }
    }
    
    // Save high scores to file
    func saveScores(_ scores: [HighScore]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(scores)
            try data.write(to: fileURL)
            print("High scores saved to: \(fileURL.path)")
        } catch {
            print("Error saving high scores: \(error)")
        }
    }
    
    // Add a new score and maintain top 10
    func addScore(initials: String, xp: Int, roomNumber: Int) {
        var scores = loadScores()
        let newScore = HighScore(initials: initials, xp: xp, roomNumber: roomNumber)
        scores.append(newScore)
        scores.sort(by: >)  // Sort highest to lowest
        
        // Keep only top 10
        if scores.count > maxScores {
            scores = Array(scores.prefix(maxScores))
        }
        
        saveScores(scores)
    }
    
    // Check if a score qualifies for the leaderboard
    func isHighScore(xp: Int) -> Bool {
        let scores = loadScores()
        if scores.count < maxScores {
            return true
        }
        return xp > scores.last!.xp
    }
}
