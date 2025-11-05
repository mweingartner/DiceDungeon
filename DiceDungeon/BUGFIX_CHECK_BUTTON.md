# Bug Fix: Check Button Not Showing Results

## Problem
When clicking the CHECK button after slotting dice, nothing appeared to happen. The goals were being evaluated correctly, but the result message was not visible to the player.

## Root Cause
In the `checkGoals()` method, after carefully crafting a message showing the results (dice values, goals met/not met, damage dealt, etc.), the code called `updateUI()` at the very end.

The `updateUI()` method has logic that sets `resultLabel.text` based on game state:
```swift
if !hasRolled {
    resultLabel.text = "Click 'ROLL DICE' to roll all dice!"
} else {
    resultLabel.text = "Click dice to place them in slots, then press 'CHECK'"
}
```

This meant that immediately after setting our detailed result message, it was being overwritten with generic instruction text!

## Solution
Instead of calling `updateUI()` at the end of `checkGoals()`, we now manually update only the specific UI elements that need to change:
- Player HP label
- Player XP label  
- Monster info label
- Monster HP label
- Check button alpha (enabled/disabled state)

This preserves the result message we set, allowing the player to see what happened with their dice roll.

## Code Changed
**File:** `GameScene.swift`
**Method:** `checkGoals()`

**Before:**
```swift
resultLabel.text = message
updateUI()
```

**After:**
```swift
resultLabel.text = message
// Don't call updateUI() here as it will overwrite the message
// Instead, update only the specific UI elements that need updating
playerHPLabel.text = "❤️ HP: \(player.currentHP)/\(player.maxHP)"
playerXPLabel.text = "⭐️ XP: \(player.experience) | Level: \(player.level)"

if let encounter = currentEncounter, let monster = encounter.currentMonster {
    monsterInfoLabel.text = "\(monster.type.emoji) \(monster.type.displayName)"
    monsterHPLabel.text = "HP: \(monster.currentHP)/\(monster.maxHP)"
}

// Update check button state
if hasRolled && !slottedDice.isEmpty {
    checkButton.alpha = 1.0
} else {
    checkButton.alpha = 0.5
}
```

## Additional Debug Logging
Also added comprehensive debug logging throughout the codebase to help diagnose issues:
- `handleDiceClick()` - logs when dice are clicked and slotted
- `checkGoals()` - logs dice values, goals being checked, and results
- `mouseDown()` CHECK button handler - logs button clicks and state

These can be removed once testing is complete, or kept for future debugging.

## Result
Players can now see:
- Which dice they slotted and their values
- Which goals were achieved (or not)
- How much damage was dealt
- Monster defeat messages
- Proper feedback for all combat actions
