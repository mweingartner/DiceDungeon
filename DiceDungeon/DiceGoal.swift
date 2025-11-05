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
            guard colorValues.count == colors.count else { return false }
            // Check if values form an ascending sequence (each value is 1 more than the previous)
            for i in 0..<(colorValues.count - 1) {
                if colorValues[i + 1] != colorValues[i] + 1 {
                    return false
                }
            }
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
