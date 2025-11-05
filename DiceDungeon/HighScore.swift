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
        print("DEBUG HighScoreManager: Attempting to load scores from: \(fileURL.path)")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("DEBUG HighScoreManager: No high scores file found, returning empty array")
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            print("DEBUG HighScoreManager: Read \(data.count) bytes from file")
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let scores = try decoder.decode([HighScore].self, from: data)
            print("DEBUG HighScoreManager: Decoded \(scores.count) scores successfully")
            
            for (index, score) in scores.enumerated() {
                print("  Score \(index): \(score.initials) - \(score.xp) XP, Room \(score.roomNumber)")
            }
            
            let sorted = scores.sorted(by: >)  // Sort highest to lowest
            print("DEBUG HighScoreManager: Returning \(sorted.count) sorted scores")
            return sorted
        } catch {
            print("ERROR HighScoreManager: Failed to load high scores: \(error)")
            print("ERROR HighScoreManager: Error details: \(error.localizedDescription)")
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
        print("DEBUG HighScoreManager: Adding score - \(initials): \(xp) XP, Room \(roomNumber)")
        
        var scores = loadScores()
        let newScore = HighScore(initials: initials, xp: xp, roomNumber: roomNumber)
        scores.append(newScore)
        scores.sort(by: >)  // Sort highest to lowest
        
        // Keep only top 10
        if scores.count > maxScores {
            scores = Array(scores.prefix(maxScores))
        }
        
        print("DEBUG HighScoreManager: Saving \(scores.count) total scores")
        saveScores(scores)
    }
    
    // Check if a score qualifies for the leaderboard
    func isHighScore(xp: Int) -> Bool {
        let scores = loadScores()
        print("DEBUG isHighScore: Checking XP \(xp) against \(scores.count) existing scores")
        
        if scores.count < maxScores {
            print("DEBUG isHighScore: Board not full (\(scores.count)/\(maxScores)), qualifies!")
            return true
        }
        
        if let lowestScore = scores.last {
            let qualifies = xp > lowestScore.xp
            print("DEBUG isHighScore: Lowest score is \(lowestScore.xp), \(xp) > \(lowestScore.xp) = \(qualifies)")
            return qualifies
        }
        
        print("DEBUG isHighScore: No scores to compare, qualifies!")
        return true
    }
}
