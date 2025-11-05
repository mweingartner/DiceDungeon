# Progressive Difficulty and Partial Reroll Changes

## Summary
This update implements two major gameplay improvements:
1. **Progressive Difficulty Scaling** - Encounters become more challenging with additional defeat criteria as the game progresses
2. **Partial Dice Reroll** - Players can lock dice in slots and reroll only the unslotted dice

## Changes Made

### 1. Progressive Difficulty System

#### Monster.swift
- Added dynamic goal scaling based on `difficultyMultiplier`
- Monsters now gain additional defeat criteria as rooms progress
- For every 50% increase in difficulty multiplier, monsters gain 1 additional goal
- Examples:
  - **Room 1**: Slime has 1 goal (pair)
  - **Room 4**: Slime has 2 goals (pair + three of a kind) 
  - **Room 7**: Slime has 3 goals (pair + three of a kind + another)

#### Encounter.swift
- Already had a good difficulty multiplier system: `1.0 + (roomNumber - 1) * 0.15`
- This means 15% HP increase per room, which also triggers additional goals every ~3 rooms

#### DiceGoal.swift
- Added `ColorMatchMode` enum with `.exact` and `.minimum` options
- Updated `DiceGoal` struct to include `colorMatchMode` parameter
- Modified color match checking to support both exact matches and minimum value requirements
- This allows goals like "Red die shows 5+" to work correctly (checking >= 5 instead of == 5)

### 2. Partial Reroll System

#### GameScene.swift - `rollAllDice()` Method
**Before**: Rolling dice would always:
- Clear all slots
- Move all dice back to original positions
- Roll all 6 dice

**After**: Rolling dice now:
- Only clears slots if no dice are slotted
- Keeps slotted dice in their positions
- Only rolls unslotted dice
- Allows strategic dice locking

**Implementation Details**:
```swift
// Check which dice are slotted
var diceToRoll: [Int] = []
for (index, dice) in self.dice.enumerated() {
    let isSlotted = slottedDice.values.contains(dice)
    if !isSlotted {
        diceToRoll.append(index)
    }
}
// Only roll the unslotted dice
```

#### GameScene.swift - `updateUI()` Method
Updated result label messages to inform players about the new reroll mechanic:
- "Click dice to place them in slots, then press 'CHECK' or 'ROLL AGAIN'"
- "Place more dice in slots or press 'CHECK'. Reroll unslotted dice anytime!"

## Gameplay Impact

### Progressive Difficulty
- Early rooms (1-3): Relatively easy with 1-2 goals per monster
- Mid rooms (4-7): Moderate challenge with 2-3 goals per monster
- Late rooms (8+): Very challenging with 3-4+ goals per monster
- Boss fights: Scale even more dramatically with difficulty

### Partial Reroll Strategy
Players can now:
1. Roll all dice initially
2. Select promising dice and slot them (e.g., a pair of 6s)
3. Reroll the remaining dice to try to complete other goals
4. Keep adding good rolls to slots
5. Check when satisfied or when all slots are filled

**Example Strategy**:
- Roll: 6, 6, 3, 2, 1, 4 (Red, Orange, Yellow, Green, Blue, Purple)
- Goal: "Three of a kind" + "Red die shows 6"
- Slot: Red 6 (satisfies one goal)
- Slot: Orange 6 (toward three of a kind)
- Reroll: Yellow, Green, Blue, Purple dice to find another 6
- If found, slot it and check for victory!

## Technical Notes

### Color Match Modes
- **Exact Mode** (`.exact`): Dice must show the exact value (e.g., "Red die shows 6")
- **Minimum Mode** (`.minimum`): Dice must show at least the value (e.g., "Red die shows 5+" means 5 or 6)

### Goal Scaling Formula
```swift
let extraGoals = max(0, Int((difficultyMultiplier - 1.0) / 0.5))
```
- Room 1: multiplier = 1.0, extraGoals = 0
- Room 4: multiplier = 1.45, extraGoals = 0
- Room 5: multiplier = 1.6, extraGoals = 1
- Room 8: multiplier = 2.05, extraGoals = 2
- Room 11: multiplier = 2.5, extraGoals = 3

### Roll Count Behavior
- First roll is free (no damage)
- Each subsequent roll costs 10 HP
- Roll count is tracked per encounter
- Slotted dice are preserved across rerolls
- Unslotted dice can be rerolled unlimited times (with HP cost)

## Testing Recommendations

1. **Test Progressive Difficulty**:
   - Play through multiple rooms
   - Verify monsters gain additional goals every few rooms
   - Check boss fights have appropriate difficulty

2. **Test Partial Reroll**:
   - Slot some dice, verify they stay put when rolling
   - Verify only unslotted dice get rerolled
   - Test edge case: all 6 dice slotted, rolling should do nothing
   - Test rolling with no dice slotted clears everything

3. **Test Color Match Modes**:
   - Verify "shows 6" goals only accept 6
   - Verify "shows 5+" goals accept 5 or 6
   - Test with progressive difficulty goals

## Future Enhancements

Possible improvements:
- Visual indicator showing which dice will be rerolled
- Animation highlighting slotted vs unslotted dice
- Sound effects for slot locking
- Different slot colors for locked vs unlocked
- Tooltip explaining the reroll mechanic on first use
