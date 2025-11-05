# Goal-Based Combat System

## Overview

The game has been refactored to remove HP-based combat and instead use a pure goal completion system. Monsters are now defeated by completing all their goals rather than by reducing their HP to zero.

## Changes Made

### Monster Class (Monster.swift)

**Removed:**
- `maxHP: Int` - No longer tracking hit points
- `currentHP: Int` - No longer tracking current health
- `damagePerRoll: Int` - No longer needed since there's no HP damage
- `takeDamage(_ damage: Int)` - No longer dealing damage
- HP-based `isDefeated` check

**Added:**
- `goalsCompleted: Set<Int>` - Tracks which goals (by index) have been completed
- `remainingGoals: [DiceGoal]` - Returns list of incomplete goals
- `completedGoals: [DiceGoal]` - Returns list of completed goals
- `markGoalCompleted(at index: Int)` - Marks a specific goal as complete
- `resetProgress()` - Clears all goal completion progress
- Goal-based `isDefeated` check - Returns true when all goals are completed

### Encounter Struct (Encounter.swift)

**Updated:**
- `totalXPValue` - Now based on goal count (goals × 10) instead of HP
- `healAmount` - Now based on total goal count instead of monster count
- `totalDamagePerRoll` - Deprecated but kept for compatibility (returns 0)

### GameScene (GameScene.swift)

**UI Updates:**
- Monster HP label now shows "Goals: X/Y" progress instead of "HP: X/Y"
- Goals display now only shows **remaining** incomplete goals
- When all goals are complete, shows "All goals complete! Monster defeated!"

**Combat Logic:**
- `checkGoals()` now marks goals as completed instead of dealing damage
- Tracks which goals are newly met vs already completed
- Shows progress messages like "Progress! 2 goal(s) remaining!"
- Monster is defeated when all goals are marked complete

### Encounter Debug Logging

The `isComplete` check in Encounter.swift now includes debug logging to help track:
- Which monsters are in the encounter
- Each monster's HP and defeated status  
- Whether all monsters are defeated
- Which monster is current (or if all are defeated)

## Benefits

1. **Clearer Game Mechanics** - The HP system was redundant when goals are what actually matter
2. **Better Progress Tracking** - Players can see exactly which goals they've completed
3. **Simpler Code** - Removed unnecessary HP tracking and damage calculation
4. **More Strategic** - Players focus on completing specific goals rather than just "dealing damage"
5. **Fixed Healing Bug** - The encounter.isComplete check now works reliably since it's based on goal completion, not HP

## Game Flow

1. Player rolls dice and slots them
2. Player clicks CHECK to evaluate goals
3. Any newly-met goals are marked as completed
4. Progress is shown: "X goal(s) remaining"
5. When all goals are complete, monster is defeated
6. When all monsters in encounter are defeated, player is fully healed
7. Next encounter begins with full HP

## Debugging

Debug output now shows:
- When goals are checked
- Which goals are already complete
- Which new goals were just met
- When a monster is defeated
- When an encounter is complete
- HP values at each healing point
