//
//  DiceGoal.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/11/25.
//

import Foundation

enum DiceGoalType {
    case pair                    // Two of the same number
    case twoPair                 // Two different pairs
    case threeOfAKind           // Three of the same number
    case fourOfAKind            // Four of the same number
    case fiveOfAKind            // Five of the same number
    case sixOfAKind             // All six the same
    case smallStraight          // Four consecutive numbers (e.g., 1,2,3,4)
    case largeStraight          // Five consecutive numbers (e.g., 2,3,4,5,6)
    case fullStraight           // 1,2,3,4,5,6
    case fullHouse              // Three of one number and two of another
    case specificNumber(Int)    // Specific number of a certain value
    case colorMatch(DiceColor)  // Specific colored die must meet certain value (exact or minimum)
    case colorPair(DiceColor, DiceColor) // Two specific colored dice must be the same value
    case colorTriple(DiceColor, DiceColor, DiceColor) // Three specific colored dice must be the same value
    case colorSum([DiceColor])  // Sum of specific colored dice must meet threshold
    case colorSequence([DiceColor]) // Specific colored dice must form an ascending sequence
    case allWarmColors          // Red, Orange, Yellow dice must all be 4+
    case allCoolColors          // Green, Blue, Purple dice must all be 4+
    case rainbowPattern         // Each pair of adjacent colors in spectrum must differ by exactly 1
    case colorOdds([DiceColor]) // Specified colored dice must all be odd
    case colorEvens([DiceColor]) // Specified colored dice must all be even
}

enum ColorMatchMode {
    case exact      // Must match exactly
    case minimum    // Must be >= the specified value
}

enum GoalTier: Int, CaseIterable {
    case basic = 1
    case common = 2
    case uncommon = 3
    case rare = 4
    case extreme = 5
}

struct DiceGoal {
    let type: DiceGoalType
    let description: String
    let difficulty: Int // 1-10 scale
    
    // For goals that require specific values on specific colored dice
    var colorRequirements: [DiceColor: Int]? = nil
    var colorMatchMode: ColorMatchMode = .exact // Whether to check exact match or minimum value
    var sumThreshold: Int? = nil // For colorSum goals
    
    init(type: DiceGoalType, description: String, difficulty: Int, colorRequirements: [DiceColor: Int]? = nil, colorMatchMode: ColorMatchMode = .exact, sumThreshold: Int? = nil) {
        self.type = type
        self.description = description
        self.difficulty = difficulty
        self.colorRequirements = colorRequirements
        self.colorMatchMode = colorMatchMode
        self.sumThreshold = sumThreshold
    }
    
    func isMet(by diceResults: [DiceResult]) -> Bool {
        let values = diceResults.map { $0.value }
        
        switch type {
        case .pair:
            return hasPair(values)
            
        case .twoPair:
            return hasTwoPair(values)
            
        case .threeOfAKind:
            return hasNOfAKind(values, n: 3)
            
        case .fourOfAKind:
            return hasNOfAKind(values, n: 4)
            
        case .fiveOfAKind:
            return hasNOfAKind(values, n: 5)
            
        case .sixOfAKind:
            return hasNOfAKind(values, n: 6)
            
        case .smallStraight:
            return hasSmallStraight(values)
            
        case .largeStraight:
            return hasLargeStraight(values)
            
        case .fullStraight:
            return hasFullStraight(values)
            
        case .fullHouse:
            return hasFullHouse(values)
            
        case .specificNumber(let target):
            return values.contains(target)
            
        case .colorMatch(let color):
            guard let colorReq = colorRequirements,
                  let requiredValue = colorReq[color],
                  let diceResult = diceResults.first(where: { $0.color == color }) else {
                return false
            }
            switch colorMatchMode {
            case .exact:
                return diceResult.value == requiredValue
            case .minimum:
                return diceResult.value >= requiredValue
            }
            
        case .colorPair(let color1, let color2):
            guard let result1 = diceResults.first(where: { $0.color == color1 }),
                  let result2 = diceResults.first(where: { $0.color == color2 }) else {
                return false
            }
            return result1.value == result2.value
            
        case .colorTriple(let color1, let color2, let color3):
            guard let result1 = diceResults.first(where: { $0.color == color1 }),
                  let result2 = diceResults.first(where: { $0.color == color2 }),
                  let result3 = diceResults.first(where: { $0.color == color3 }) else {
                return false
            }
            return result1.value == result2.value && result2.value == result3.value
            
        case .colorSum(let colors):
            guard let threshold = sumThreshold else { return false }
            let sum = colors.compactMap { color in
                diceResults.first(where: { $0.color == color })?.value
            }.reduce(0, +)
            return colors.allSatisfy({ color in diceResults.contains(where: { $0.color == color })}) && sum >= threshold
            
        case .colorSequence(let colors):
            let colorValues = colors.compactMap { color in
                diceResults.first(where: { $0.color == color })?.value
            }
            
            // Debug output
            print("DEBUG colorSequence: Checking colors \(colors.map { $0.rawValue })")
            for color in colors {
                if let result = diceResults.first(where: { $0.color == color }) {
                    print("  \(color.rawValue): \(result.value)")
                } else {
                    print("  \(color.rawValue): NOT FOUND")
                }
            }
            print("  colorValues array: \(colorValues)")
            
            guard colorValues.count == colors.count else {
                print("  FAILED: Not all colors found (\(colorValues.count) vs \(colors.count))")
                return false
            }
            
            // Check if values form a strictly ascending sequence (each value is 1 more than the previous)
            for i in 0..<(colorValues.count - 1) {
                if colorValues[i + 1] != colorValues[i] + 1 {
                    print("  FAILED: Values not consecutive - \(colorValues[i]) then \(colorValues[i+1])")
                    return false
                }
            }
            
            print("  SUCCESS: Valid ascending sequence!")
            return true
            
        case .allWarmColors:
            let warmColors: [DiceColor] = [.red, .orange, .yellow]
            return warmColors.allSatisfy { color in
                if let result = diceResults.first(where: { $0.color == color }) {
                    return result.value >= 4
                }
                return false
            }
            
        case .allCoolColors:
            let coolColors: [DiceColor] = [.green, .blue, .purple]
            return coolColors.allSatisfy { color in
                if let result = diceResults.first(where: { $0.color == color }) {
                    return result.value >= 4
                }
                return false
            }
            
        case .rainbowPattern:
            // Check if Red→Orange, Orange→Yellow, Yellow→Green, Green→Blue, Blue→Purple each differ by exactly 1
            let colorPairs: [(DiceColor, DiceColor)] = [
                (.red, .orange), (.orange, .yellow), (.yellow, .green),
                (.green, .blue), (.blue, .purple)
            ]
            return colorPairs.allSatisfy { color1, color2 in
                guard let val1 = diceResults.first(where: { $0.color == color1 })?.value,
                      let val2 = diceResults.first(where: { $0.color == color2 })?.value else {
                    return false
                }
                return abs(val1 - val2) == 1
            }
            
        case .colorOdds(let colors):
            return colors.allSatisfy { color in
                if let result = diceResults.first(where: { $0.color == color }) {
                    return result.value % 2 == 1
                }
                return false
            }
            
        case .colorEvens(let colors):
            return colors.allSatisfy { color in
                if let result = diceResults.first(where: { $0.color == color }) {
                    return result.value % 2 == 0
                }
                return false
            }
        }
    }
    
    // Helper methods for checking dice combinations
    private func hasPair(_ values: [Int]) -> Bool {
        let counts = valueCounts(values)
        return counts.values.contains(where: { $0 >= 2 })
    }
    
    private func hasTwoPair(_ values: [Int]) -> Bool {
        let counts = valueCounts(values)
        let pairs = counts.values.filter { $0 >= 2 }
        return pairs.count >= 2
    }
    
    private func hasNOfAKind(_ values: [Int], n: Int) -> Bool {
        let counts = valueCounts(values)
        return counts.values.contains(where: { $0 >= n })
    }
    
    private func hasSmallStraight(_ values: [Int]) -> Bool {
        let unique = Set(values).sorted()
        return hasConsecutive(unique, length: 4)
    }
    
    private func hasLargeStraight(_ values: [Int]) -> Bool {
        let unique = Set(values).sorted()
        return hasConsecutive(unique, length: 5)
    }
    
    private func hasFullStraight(_ values: [Int]) -> Bool {
        let sorted = values.sorted()
        return sorted == [1, 2, 3, 4, 5, 6]
    }
    
    private func hasFullHouse(_ values: [Int]) -> Bool {
        let counts = valueCounts(values)
        let countValues = Array(counts.values).sorted()
        return countValues == [2, 3] || countValues == [3, 3]
    }
    
    private func hasConsecutive(_ sorted: [Int], length: Int) -> Bool {
        guard sorted.count >= length else { return false }
        
        for i in 0...(sorted.count - length) {
            var isConsecutive = true
            for j in 0..<(length - 1) {
                if sorted[i + j + 1] != sorted[i + j] + 1 {
                    isConsecutive = false
                    break
                }
            }
            if isConsecutive {
                return true
            }
        }
        return false
    }
    
    private func valueCounts(_ values: [Int]) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        for value in values {
            counts[value, default: 0] += 1
        }
        return counts
    }
}

struct DiceResult {
    let color: DiceColor
    let value: Int
}

struct DiceGoalFactory {
    struct GoalOption {
        let tier: GoalTier
        let weight: Int
        let build: () -> DiceGoal
    }
    
    static func generateGoals(count: Int, playerLevel: Int) -> [DiceGoal] {
        let goalCount = max(1, count)
        let tierWeights = weights(for: playerLevel)
        let options = goalOptions()
        
        var goals: [DiceGoal] = []
        var usedDescriptions: Set<String> = []
        
        for _ in 0..<goalCount {
            var attempts = 0
            while attempts < 12 {
                attempts += 1
                let tier = weightedPick(tierWeights)
                let candidates = options.filter { $0.tier == tier }
                if let option = weightedPickOption(candidates) {
                    let goal = option.build()
                    if !usedDescriptions.contains(goal.description) {
                        usedDescriptions.insert(goal.description)
                        goals.append(goal)
                        break
                    }
                }
            }
        }
        
        if goals.count < goalCount {
            let fallback = DiceGoal(type: .pair, description: "Roll any pair", difficulty: 1)
            while goals.count < goalCount {
                goals.append(fallback)
            }
        }
        
        return goals
    }
    
    private static func weights(for level: Int) -> [(GoalTier, Int)] {
        switch level {
        case ...1:
            return [(.basic, 60), (.common, 25), (.uncommon, 12), (.rare, 3), (.extreme, 0)]
        case 2:
            return [(.basic, 45), (.common, 30), (.uncommon, 18), (.rare, 7), (.extreme, 0)]
        case 3:
            return [(.basic, 30), (.common, 30), (.uncommon, 25), (.rare, 12), (.extreme, 3)]
        case 4:
            return [(.basic, 20), (.common, 28), (.uncommon, 28), (.rare, 16), (.extreme, 8)]
        case 5:
            return [(.basic, 12), (.common, 24), (.uncommon, 30), (.rare, 20), (.extreme, 14)]
        case 6:
            return [(.basic, 8), (.common, 20), (.uncommon, 30), (.rare, 24), (.extreme, 18)]
        default:
            return [(.basic, 5), (.common, 18), (.uncommon, 28), (.rare, 27), (.extreme, 22)]
        }
    }
    
    private static func goalOptions() -> [GoalOption] {
        return [
            GoalOption(tier: .basic, weight: 3, build: { DiceGoal(type: .pair, description: "Roll any pair", difficulty: 1) }),
            GoalOption(tier: .basic, weight: 3, build: {
                let value = Int.random(in: 1...6)
                return DiceGoal(type: .specificNumber(value), description: "Roll a \(value)", difficulty: 1)
            }),
            GoalOption(tier: .basic, weight: 3, build: {
                let color = randomColor()
                let minValue = Int.random(in: 3...4)
                return DiceGoal(type: .colorMatch(color), description: "\(color.displayName) die shows \(minValue)+", difficulty: 2,
                                colorRequirements: [color: minValue], colorMatchMode: .minimum)
            }),
            GoalOption(tier: .basic, weight: 2, build: {
                let colors = randomDistinctColors(count: 2)
                return DiceGoal(type: .colorOdds(colors), description: "\(colors[0].displayName) & \(colors[1].displayName) both odd", difficulty: 2)
            }),
            GoalOption(tier: .basic, weight: 2, build: {
                let colors = randomDistinctColors(count: 2)
                return DiceGoal(type: .colorEvens(colors), description: "\(colors[0].displayName) & \(colors[1].displayName) both even", difficulty: 2)
            }),
            GoalOption(tier: .common, weight: 3, build: { DiceGoal(type: .twoPair, description: "Roll two pairs", difficulty: 3) }),
            GoalOption(tier: .common, weight: 3, build: { DiceGoal(type: .threeOfAKind, description: "Roll three of a kind", difficulty: 3) }),
            GoalOption(tier: .common, weight: 2, build: {
                let colors = randomDistinctColors(count: 2)
                return DiceGoal(type: .colorPair(colors[0], colors[1]), description: "\(colors[0].displayName) & \(colors[1].displayName) match", difficulty: 3)
            }),
            GoalOption(tier: .common, weight: 2, build: {
                let colors = randomDistinctColors(count: 2)
                let threshold = Int.random(in: 8...10)
                return DiceGoal(type: .colorSum(colors), description: "\(colors[0].displayName) + \(colors[1].displayName) = \(threshold)+", difficulty: 3, sumThreshold: threshold)
            }),
            GoalOption(tier: .uncommon, weight: 3, build: { DiceGoal(type: .smallStraight, description: "Roll a small straight (4 consecutive)", difficulty: 4) }),
            GoalOption(tier: .uncommon, weight: 2, build: { DiceGoal(type: .fullHouse, description: "Roll a full house", difficulty: 4) }),
            GoalOption(tier: .uncommon, weight: 2, build: {
                let colors = randomDistinctColors(count: 3)
                return DiceGoal(type: .colorTriple(colors[0], colors[1], colors[2]), description: "\(colors[0].displayName), \(colors[1].displayName) & \(colors[2].displayName) all match", difficulty: 5)
            }),
            GoalOption(tier: .uncommon, weight: 2, build: { DiceGoal(type: .allWarmColors, description: "Red, Orange & Yellow all 4+", difficulty: 4) }),
            GoalOption(tier: .uncommon, weight: 2, build: { DiceGoal(type: .allCoolColors, description: "Green, Blue & Purple all 4+", difficulty: 4) }),
            GoalOption(tier: .uncommon, weight: 1, build: {
                let colors = randomDistinctColors(count: 3)
                return DiceGoal(type: .colorSequence(colors), description: "\(colors[0].displayName)→\(colors[1].displayName)→\(colors[2].displayName) ascending", difficulty: 5)
            }),
            GoalOption(tier: .rare, weight: 3, build: { DiceGoal(type: .fourOfAKind, description: "Roll four of a kind", difficulty: 6) }),
            GoalOption(tier: .rare, weight: 2, build: { DiceGoal(type: .largeStraight, description: "Roll a large straight (5 consecutive)", difficulty: 7) }),
            GoalOption(tier: .rare, weight: 2, build: {
                let colors = randomDistinctColors(count: 3)
                let threshold = Int.random(in: 12...15)
                return DiceGoal(type: .colorSum(colors), description: "\(colors[0].displayName) + \(colors[1].displayName) + \(colors[2].displayName) = \(threshold)+", difficulty: 6, sumThreshold: threshold)
            }),
            GoalOption(tier: .rare, weight: 1, build: { DiceGoal(type: .rainbowPattern, description: "Rainbow pattern (adjacent colors differ by 1)", difficulty: 7) }),
            GoalOption(tier: .extreme, weight: 2, build: { DiceGoal(type: .fiveOfAKind, description: "Roll five of a kind", difficulty: 8) }),
            GoalOption(tier: .extreme, weight: 1, build: { DiceGoal(type: .sixOfAKind, description: "Roll six of a kind", difficulty: 9) }),
            GoalOption(tier: .extreme, weight: 1, build: { DiceGoal(type: .fullStraight, description: "Roll 1-6 straight", difficulty: 9) }),
            GoalOption(tier: .extreme, weight: 1, build: {
                let colors = randomDistinctColors(count: 5)
                return DiceGoal(type: .colorSequence(colors), description: "\(colors[0].displayName)→\(colors[1].displayName)→\(colors[2].displayName)→\(colors[3].displayName)→\(colors[4].displayName) ascending", difficulty: 8)
            })
        ]
    }
    
    private static func weightedPick(_ weights: [(GoalTier, Int)]) -> GoalTier {
        let total = weights.reduce(0) { $0 + $1.1 }
        let roll = Int.random(in: 1...max(1, total))
        var running = 0
        for (tier, weight) in weights {
            running += weight
            if roll <= running {
                return tier
            }
        }
        return .basic
    }
    
    private static func weightedPickOption(_ options: [GoalOption]) -> GoalOption? {
        guard !options.isEmpty else { return nil }
        let total = options.reduce(0) { $0 + $1.weight }
        let roll = Int.random(in: 1...max(1, total))
        var running = 0
        for option in options {
            running += option.weight
            if roll <= running {
                return option
            }
        }
        return options.first
    }
    
    private static func randomColor() -> DiceColor {
        return DiceColor.allCases.randomElement() ?? .red
    }
    
    private static func randomDistinctColors(count: Int) -> [DiceColor] {
        let colors = DiceColor.allCases.shuffled()
        let clamped = min(max(1, count), colors.count)
        return Array(colors.prefix(clamped))
    }
}
