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
    var maxMana: Int = 3
    var currentMana: Int = 3
    
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
        while experience >= xpForNextLevel {
            level += 1
            maxHP += 10
            
            // Increase max mana every 3 levels
            if level % 3 == 0 {
                maxMana += 1
            }
            
            xpForNextLevel = level * 100
        }
        // Full heal and mana restore after all level ups
        currentHP = maxHP
        currentMana = maxMana
    }
    
    var isAlive: Bool {
        return currentHP > 0
    }
}
