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
    static func generateEncounter(roomNumber: Int, playerLevel: Int) -> Encounter {
        let monsterTypes = selectMonsterTypes(for: playerLevel)
        let monsterCount = selectMonsterCount()
        let minGoals = min(playerLevel, 10)
        let goalsUpperBound = min(10, max(playerLevel + 2, playerLevel))
        let goalsPerEncounter = Int.random(in: minGoals...goalsUpperBound)
        
        var monsters: [Monster] = []
        for _ in 0..<monsterCount {
            let type = monsterTypes.randomElement() ?? .slime
            let goals = DiceGoalFactory.generateGoals(count: goalsPerEncounter, playerLevel: playerLevel)
            let monster = Monster(type: type, goals: goals)
            monsters.append(monster)
        }
        
        return Encounter(monsters: monsters, roomNumber: roomNumber)
    }
    
    private static func selectMonsterTypes(for playerLevel: Int) -> [MonsterType] {
        switch playerLevel {
        case ...2:
            return [.slime, .rat, .spider, .bat]
        case 3...4:
            return [.goblin, .skeleton, .zombie, .orc, .ghost]
        case 5...6:
            return [.troll, .vampire, .werewolf, .demon]
        default:
            return [.troll, .vampire, .werewolf, .demon]
        }
    }
    
    private static func selectMonsterCount() -> Int {
        return 1
    }
    
    // Generate a boss encounter
    static func generateBossEncounter(roomNumber: Int, playerLevel: Int) -> Encounter {
        let bossType = [MonsterType.dragon, .lich, .hydra].randomElement() ?? .dragon
        let minGoals = min(playerLevel, 10)
        let goalsUpperBound = min(10, max(playerLevel + 2, playerLevel))
        let goalsPerEncounter = Int.random(in: minGoals...goalsUpperBound)
        let goals = DiceGoalFactory.generateGoals(count: goalsPerEncounter, playerLevel: playerLevel)
        let boss = Monster(type: bossType, goals: goals)
        
        return Encounter(monsters: [boss], roomNumber: roomNumber)
    }
}
