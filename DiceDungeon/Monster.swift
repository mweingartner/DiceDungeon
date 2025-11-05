//
//  Monster.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/11/25.
//

import Foundation

enum MonsterType: String, CaseIterable {
    // Easy monsters (1-2 difficulty)
    case slime
    case rat
    case spider
    case bat
    
    // Medium monsters (3-5 difficulty)
    case goblin
    case skeleton
    case zombie
    case orc
    case ghost
    
    // Hard monsters (6-8 difficulty)
    case troll
    case vampire
    case werewolf
    case demon
    
    // Boss monsters (9-10 difficulty)
    case dragon
    case lich
    case hydra
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .slime: return "🟢"
        case .rat: return "🐀"
        case .spider: return "🕷️"
        case .bat: return "🦇"
        case .goblin: return "👺"
        case .skeleton: return "💀"
        case .zombie: return "🧟"
        case .orc: return "👹"
        case .ghost: return "👻"
        case .troll: return "🧌"
        case .vampire: return "🧛"
        case .werewolf: return "🐺"
        case .demon: return "😈"
        case .dragon: return "🐉"
        case .lich: return "☠️"
        case .hydra: return "🐍"
        }
    }
}

class Monster {
    let type: MonsterType
    let goals: [DiceGoal]
    private(set) var goalsCompleted: Set<Int> = [] // Track which goals have been met by index
    
    init(type: MonsterType, goals: [DiceGoal]) {
        self.type = type
        self.goals = goals
    }
    
    var isDefeated: Bool {
        // Monster is defeated when all goals are completed
        return goalsCompleted.count == goals.count
    }
    
    var remainingGoals: [DiceGoal] {
        return goals.enumerated().filter { !goalsCompleted.contains($0.offset) }.map { $0.element }
    }
    
    var completedGoals: [DiceGoal] {
        return goals.enumerated().filter { goalsCompleted.contains($0.offset) }.map { $0.element }
    }
    
    func markGoalCompleted(at index: Int) {
        guard index >= 0 && index < goals.count else { return }
        goalsCompleted.insert(index)
    }
    
    func resetProgress() {
        goalsCompleted.removeAll()
    }
    
    // Factory method to create monsters based on difficulty
    static func create(type: MonsterType, difficultyMultiplier: Double = 1.0) -> Monster {
        var goals: [DiceGoal] = []
        
        // Calculate how many extra goals to add based on difficulty multiplier
        // For every 50% increase in difficulty, add 1 more goal requirement
        let extraGoals = max(0, Int((difficultyMultiplier - 1.0) / 0.5))
        
        switch type {
        // Easy monsters
        case .slime:
            goals = [
                DiceGoal(type: .colorMatch(.green), description: "Green die shows 3+", difficulty: 1,
                        colorRequirements: [.green: 3], colorMatchMode: .minimum)
            ]
            // Add progressive goals
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .pair, description: "Roll any pair", difficulty: 1))
            }
            
        case .rat:
            goals = [
                DiceGoal(type: .colorOdds([.red, .orange]), description: "Red & Orange both odd", difficulty: 2)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .pair, description: "Roll any pair", difficulty: 1))
            }
            
        case .spider:
            goals = [
                DiceGoal(type: .colorSum([.green, .yellow]), description: "Green + Yellow = 10+", difficulty: 2,
                        sumThreshold: 10)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .twoPair, description: "Roll two pairs", difficulty: 2))
            }
            
        case .bat:
            goals = [
                DiceGoal(type: .colorPair(.blue, .purple), description: "Blue and Purple match", difficulty: 2)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .threeOfAKind, description: "Roll three of a kind", difficulty: 2))
            }
            
        // Medium monsters
        case .goblin:
            goals = [
                DiceGoal(type: .colorEvens([.red, .yellow]), description: "Red & Yellow both even", difficulty: 3)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .threeOfAKind, description: "Roll three of a kind", difficulty: 3))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .colorMatch(.orange), description: "Orange die shows 4+", difficulty: 2,
                                    colorRequirements: [.orange: 4], colorMatchMode: .minimum))
            }
            
        case .skeleton:
            goals = [
                DiceGoal(type: .colorSequence([.red, .orange, .yellow]), description: "Red→Orange→Yellow ascending", difficulty: 4)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .fullHouse, description: "Roll a full house", difficulty: 4))
            }
            
        case .zombie:
            goals = [
                DiceGoal(type: .colorPair(.red, .green), description: "Red & Green match", difficulty: 3)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .threeOfAKind, description: "Roll three of a kind", difficulty: 3))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .colorSum([.red, .orange, .yellow]), description: "Red + Orange + Yellow = 12+", difficulty: 4,
                                    sumThreshold: 12))
            }
            
        case .orc:
            goals = [
                DiceGoal(type: .allWarmColors, description: "Red, Orange & Yellow all 4+", difficulty: 4)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .smallStraight, description: "Roll a small straight (4 consecutive)", difficulty: 4))
            }
            
        case .ghost:
            goals = [
                DiceGoal(type: .allCoolColors, description: "Green, Blue & Purple all 4+", difficulty: 4)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .colorMatch(.purple), description: "Purple die shows 5+", difficulty: 4,
                        colorRequirements: [.purple: 5], colorMatchMode: .minimum))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .twoPair, description: "Roll two pairs", difficulty: 3))
            }
            
        // Hard monsters
        case .troll:
            goals = [
                DiceGoal(type: .colorSum([.green, .blue, .purple]), description: "Green + Blue + Purple = 13+", difficulty: 5,
                        sumThreshold: 13)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .fourOfAKind, description: "Roll four of a kind", difficulty: 6))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .colorPair(.green, .blue), description: "Green and Blue match", difficulty: 4))
            }
            
        case .vampire:
            goals = [
                DiceGoal(type: .colorSequence([.red, .orange, .yellow, .green]), description: "Red→Orange→Yellow→Green ascending", difficulty: 7)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .smallStraight, description: "Roll a small straight (4 consecutive)", difficulty: 6))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .fullHouse, description: "Roll a full house", difficulty: 5))
            }
            
        case .werewolf:
            goals = [
                DiceGoal(type: .colorTriple(.yellow, .green, .blue), description: "Yellow, Green & Blue all match", difficulty: 7)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .fourOfAKind, description: "Roll four of a kind", difficulty: 6))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .colorOdds([.green, .blue]), description: "Green & Blue both odd", difficulty: 5))
            }
            
        case .demon:
            goals = [
                DiceGoal(type: .allWarmColors, description: "Red, Orange & Yellow all 4+", difficulty: 6),
                DiceGoal(type: .fourOfAKind, description: "Roll four of a kind", difficulty: 6)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .fullHouse, description: "Roll a full house", difficulty: 5))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .largeStraight, description: "Roll a large straight (5 consecutive)", difficulty: 7))
            }
            
        // Boss monsters
        case .dragon:
            goals = [
                DiceGoal(type: .largeStraight, description: "Roll a large straight (5 consecutive)", difficulty: 7),
                DiceGoal(type: .allWarmColors, description: "Red, Orange & Yellow all 4+", difficulty: 6)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .fourOfAKind, description: "Roll four of a kind", difficulty: 6))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .colorSum([.red, .orange, .yellow]), description: "Red + Orange + Yellow = 15+", difficulty: 7,
                                    sumThreshold: 15))
            }
            
        case .lich:
            goals = [
                DiceGoal(type: .allCoolColors, description: "Green, Blue & Purple all 4+", difficulty: 7),
                DiceGoal(type: .fullHouse, description: "Roll a full house", difficulty: 6)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .fiveOfAKind, description: "Roll five of a kind (Yahtzee!)", difficulty: 8))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .largeStraight, description: "Roll a large straight (5 consecutive)", difficulty: 7))
            }
            
        case .hydra:
            goals = [
                DiceGoal(type: .fullStraight, description: "Roll 1-6 straight", difficulty: 8),
                DiceGoal(type: .colorSum([.green, .blue, .purple]), description: "Green + Blue + Purple = 14+", difficulty: 7,
                        sumThreshold: 14)
            ]
            if extraGoals >= 1 {
                goals.append(DiceGoal(type: .fourOfAKind, description: "Roll four of a kind", difficulty: 6))
            }
            if extraGoals >= 2 {
                goals.append(DiceGoal(type: .fullHouse, description: "Roll a full house", difficulty: 6))
            }
        }
        
        return Monster(type: type, goals: goals)
    }
}
