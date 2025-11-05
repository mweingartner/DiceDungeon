//
//  Encounter.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/11/25.
//

import Foundation

class Encounter {
    let monsters: [Monster]
    let roomNumber: Int
    
    init(monsters: [Monster], roomNumber: Int) {
        self.monsters = monsters
        self.roomNumber = roomNumber
    }
    
    var isComplete: Bool {
        let result = monsters.allSatisfy { $0.isDefeated }
        print("DEBUG Encounter.isComplete: Checking \(monsters.count) monsters, all defeated: \(result)")
        for (index, monster) in monsters.enumerated() {
            print("  Monster \(index): \(monster.type.displayName) goals: \(monster.goalsCompleted.count)/\(monster.goals.count) defeated: \(monster.isDefeated)")
        }
        return result
    }
    
    var currentMonster: Monster? {
        let current = monsters.first { !$0.isDefeated }
        if let current = current {
            print("DEBUG Encounter.currentMonster: \(current.type.displayName) goals: \(current.goalsCompleted.count)/\(current.goals.count)")
        } else {
            print("DEBUG Encounter.currentMonster: nil (all defeated)")
        }
        return current
    }
    
    var totalDamagePerRoll: Int {
        // No longer needed, but keeping for compatibility if referenced elsewhere
        return 0
    }
    
    var totalXPValue: Int {
        // XP based on number of goals across all monsters
        return monsters.reduce(0) { $0 + $1.goals.count * 10 }
    }
    
    var healAmount: Int {
        // Heal amount based on difficulty (number of total goals)
        let totalGoals = monsters.reduce(0) { $0 + $1.goals.count }
        return 10 + (totalGoals * 5)
    }
}

class EncounterGenerator {
    
    // Generate an encounter based on room number (progressive difficulty)
    static func generateEncounter(roomNumber: Int) -> Encounter {
        let difficulty = calculateDifficulty(for: roomNumber)
        let monsterTypes = selectMonsterTypes(for: difficulty)
        let monsterCount = selectMonsterCount(for: difficulty, roomNumber: roomNumber)
        
        var monsters: [Monster] = []
        let difficultyMultiplier = 1.0 + (Double(roomNumber - 1) * 0.15) // 15% HP increase per room
        
        for _ in 0..<monsterCount {
            let type = monsterTypes.randomElement()!
            let monster = Monster.create(type: type, difficultyMultiplier: difficultyMultiplier)
            monsters.append(monster)
        }
        
        return Encounter(monsters: monsters, roomNumber: roomNumber)
    }
    
    private static func calculateDifficulty(for roomNumber: Int) -> Int {
        // Difficulty increases with room number
        // Rooms 1-3: Easy (1-2)
        // Rooms 4-7: Medium (3-5)
        // Rooms 8-12: Hard (6-8)
        // Rooms 13+: Boss (9-10)
        
        switch roomNumber {
        case 1...3:
            return Int.random(in: 1...2)
        case 4...7:
            return Int.random(in: 3...5)
        case 8...12:
            return Int.random(in: 6...8)
        default:
            return Int.random(in: 9...10)
        }
    }
    
    private static func selectMonsterTypes(for difficulty: Int) -> [MonsterType] {
        switch difficulty {
        case 1...2:
            return [.slime, .rat, .spider, .bat]
        case 3...5:
            return [.goblin, .skeleton, .zombie, .orc, .ghost]
        case 6...8:
            return [.troll, .vampire, .werewolf, .demon]
        case 9...10:
            return [.dragon, .lich, .hydra]
        default:
            return [.slime]
        }
    }
    
    private static func selectMonsterCount(for difficulty: Int, roomNumber: Int) -> Int {
        // One monster per room for simpler, more focused encounters
        return 1
    }
    
    // Generate a boss encounter
    static func generateBossEncounter(roomNumber: Int) -> Encounter {
        let bossType = [MonsterType.dragon, .lich, .hydra].randomElement()!
        let difficultyMultiplier = 1.0 + (Double(roomNumber) * 0.2)
        let boss = Monster.create(type: bossType, difficultyMultiplier: difficultyMultiplier)
        
        return Encounter(monsters: [boss], roomNumber: roomNumber)
    }
}
