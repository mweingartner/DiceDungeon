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
    
    func takeDamage(_ damage: Int) {
        currentHP = max(0, currentHP - damage)
    }
    
    func heal(_ amount: Int) {
        currentHP = min(maxHP, currentHP + amount)
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
            xpForNextLevel = level * 100
        }
        // Full heal after all level ups
        currentHP = maxHP
    }
    
    var isAlive: Bool {
        return currentHP > 0
    }
}
