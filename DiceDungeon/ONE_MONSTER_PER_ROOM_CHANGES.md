# One Monster Per Room and Dice Reset Changes

## Overview
Modified the game to have exactly one monster per room (instead of 1-3), and added dice reset functionality so all dice show 1 pip at the start of each new encounter, providing a clear visual indicator that a new encounter has begun.

## Changes Made

### 1. Encounter.swift - Single Monster Per Room

#### selectMonsterCount() Function
**Before:**
```swift
private static func selectMonsterCount(for difficulty: Int, roomNumber: Int) -> Int {
    // Earlier rooms have more monsters, later rooms have fewer but tougher monsters
    let baseCount: Int
    
    switch difficulty {
    case 1...2:
        baseCount = Int.random(in: 1...3)
    case 3...5:
        baseCount = Int.random(in: 1...2)
    case 6...8:
        baseCount = Int.random(in: 1...2)
    case 9...10:
        baseCount = 1 // Boss fights are always solo
    default:
        baseCount = 1
    }
    
    return baseCount
}
```

**After:**
```swift
private static func selectMonsterCount(for difficulty: Int, roomNumber: Int) -> Int {
    // One monster per room for simpler, more focused encounters
    return 1
}
```

**Impact**: 
- All encounters (regular and boss) now generate exactly 1 monster
- Simplifies gameplay - one goal per room
- Makes progression more predictable
- Eliminates the need for "rest between monsters" transitions

### 2. GameScene.swift - Dice Reset Functionality

#### New Function: resetDiceToOne()
Added a new function to reset all dice to show 1 pip:

```swift
private func resetDiceToOne() {
    // Reset all dice to show 1 pip
    for dice in self.dice {
        dice.setValue(1)
    }
}
```

**Purpose**: 
- Provides visual feedback that a new encounter has started
- Resets the game state visually
- Makes it clear to the player that they're starting fresh

#### Updated Functions

##### prepareNextEncounter()
- Added call to `resetDiceToOne()` before updating UI
- Dice now show 1 pip when entering a new room after completing the previous one

##### startNewGame()
- Added call to `resetDiceToOne()` after clearing slots
- Ensures new game starts with all dice showing 1 pip

##### runFromEncounter()
- Added call to `resetDiceToOne()` before resetting buttons
- When player runs from encounter, dice reset for the new room

## Gameplay Impact

### Simplified Encounters
- **One monster per room**: Focuses gameplay on completing a single set of goals
- **Clearer objectives**: Player knows exactly what they need to defeat
- **Faster pacing**: No more waiting between multiple monsters in one room
- **Easier balancing**: Monster difficulty is now the primary challenge scaling

### Visual Feedback
- **Dice reset to 1 pip**: Clear indication that a new encounter has begun
- **Consistent starting state**: Every room starts with the same visual state
- **Better player awareness**: Immediately know when you're in a new encounter

## Functions No Longer Used

Since there's only 1 monster per room, these functions/code paths are now obsolete but kept for code stability:

- `restBetweenMonsters()` - Never called since there are no multiple monsters
- `handleMonsterDefeated()` - Never called since encounter completes after single monster
- `dismissRestPanel()` - Associated with rest between monsters

These could be removed in a future refactor, but leaving them doesn't cause issues.

## Testing Checklist

- ✅ New game starts with all dice showing 1 pip
- ✅ Completing a room resets dice to 1 pip for next room
- ✅ Running from encounter resets dice to 1 pip in new room
- ✅ Each room has exactly 1 monster
- ✅ Boss rooms (every 5th) have exactly 1 boss monster
- ✅ No "rest between monsters" transitions occur
- ✅ All encounters go directly to reward panel after monster defeat
- ✅ Game progression feels smoother and more focused

## Future Considerations

### Difficulty Adjustment
With only 1 monster per room, you may want to:
- Increase monster goal complexity
- Add more challenging goal combinations
- Increase HP scaling per room
- Make boss encounters more difficult

### UI Cleanup
Consider removing:
- "One Down!" rest panel code (restBetweenMonsters)
- "More monsters remain" messaging
- Related transition animations that are no longer used

### Alternative Enhancements
- Add special "double monster" rooms as rare events
- Create mini-boss rooms every 3 rooms (in addition to boss every 5)
- Vary monster difficulty within same room number for variety
