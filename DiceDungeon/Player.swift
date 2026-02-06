//
//  Player.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/11/25.
//

import Foundation

class Player {
    var maxHP: Int = 100
    var currentHP: Int = 100
    var experience: Int = 0
    var level: Int = 1
    
    // New Resource: Mana
    var maxMana: Int = 5
    var currentMana: Int = 5
    
    func takeDamage(_ damage: Int) {
        currentHP = max(0, currentHP - damage)
    }
    
    func heal(_ amount: Int) {
        currentHP = min(maxHP, currentHP + amount)
    }
    
    func useMana(_ amount: Int) -> Bool {
        if currentMana >= amount {
            currentMana -= amount
            return true
        }
        return false
    }
    
    func restoreMana() {
        currentMana = maxMana
    }
    
    func gainExperience(_ xp: Int) {
        experience += xp
        checkLevelUp()
    }
    
    private func checkLevelUp() {
        // Keep leveling up while player has enough XP
        var xpForNextLevel = level * 100
        var leveledUp = false
        while experience >= xpForNextLevel {
            level += 1
            maxHP += 10
            maxMana = manaForLevel(level)
            xpForNextLevel = level * 100
            leveledUp = true
        }
        // Full heal and mana restore only when leveling up
        if leveledUp {
            currentHP = maxHP
            currentMana = maxMana
        }
    }
    
    private func manaForLevel(_ level: Int) -> Int {
        if level == 1 {
            return 5
        }
        if level == 2 {
            return 7
        }
        return 9
    }
    
    var isAlive: Bool {
        return currentHP > 0
    }
}
