# Monster Transition & Rest System Implementation

## Overview
Implemented automatic cycling to the next monster within an encounter, with a rest and full HP restoration between monsters. This distinguishes between defeating a single monster (quick rest) and completing an entire encounter/room (full rest with rewards).

## Changes Made

### 1. Modified `GameScene.swift`

#### Added Property
- `restCompletionHandler: (() -> Void)?` - Stores completion handler for rest panel dismissal between monsters

#### Modified `checkGoals()` Method
Now properly handles three scenarios when a monster is defeated:

1. **All monsters in encounter defeated** → Call `handleEncounterComplete()` (full rest + XP + next room)
2. **Monster defeated, more remain** → Call `handleMonsterDefeated()` (quick rest + next monster)
3. **Monster still alive** → Continue combat

Updated both paths (all goals met + partial goals met) to check if the encounter is complete and route appropriately.

#### New Method: `handleMonsterDefeated(message:)`
Handles transition when a monster is defeated but more remain:
1. Disables buttons during animation
2. Clears dice slots
3. Shows brief defeat animation
4. Transitions to rest between monsters

#### New Method: `showMonsterDefeatedTransition(message:completion:)`
Quick defeat animation for single monsters (shorter than full encounter):
- Shows "💀 DEFEATED! 💀" label (smaller, faster)
- Brief flash of monster info
- 0.5 second duration (vs 1 second for full encounter)
- Calls completion to show rest panel

#### New Method: `restBetweenMonsters()`
Creates and displays the quick rest panel between monsters:
- **Heals player to full HP**
- Shows "⚡️ Quick Rest ⚡️" title
- Displays HP restored amount
- Shows next monster preview with emoji and name
- "Press SPACE or click to continue" prompt
- Animated panel appearance
- Stores completion handler for dismissal

#### New Method: `dismissRestPanel()`
Handles dismissing the quick rest panel:
- Animates panel away (fade + scale)
- Removes panel from scene
- Calls `continueToNextMonster()`

#### New Method: `continueToNextMonster()`
Prepares the game state for the next monster in the same room:
- Resets `hasRolled` and `rollCount` (fresh start for each monster)
- Clears all dice slots
- Re-enables buttons
- Updates UI to show the next monster's info
- Shows "Ready to face the next monster!" message

#### Modified Input Handlers: `mouseDown(with:)` and `keyDown(with:)`
- Added check for "restPanel" (in addition to existing "rewardPanel")
- If rest panel is showing, calls the rest completion handler
- This allows player to dismiss the panel with SPACE or click

## Flow Diagrams

### Single Monster Defeated (More Remain)
```
Player defeats monster (goals met)
        ↓
Monster HP reaches 0
        ↓
encounter.isComplete == false
        ↓
handleMonsterDefeated()
        ↓
showMonsterDefeatedTransition()
    (Brief 💀 DEFEATED! animation)
        ↓
restBetweenMonsters()
    (⚡️ Quick Rest panel)
    - Heal to full HP
    - Show next monster preview
        ↓
Player presses SPACE or clicks
        ↓
dismissRestPanel()
        ↓
continueToNextMonster()
    - Reset roll count
    - Update UI with new monster
        ↓
Ready to fight next monster!
```

### All Monsters Defeated (Encounter Complete)
```
Player defeats final monster
        ↓
All monsters HP <= 0
        ↓
encounter.isComplete == true
        ↓
handleEncounterComplete()
        ↓
playMonsterDeathAnimation()
    (Full 💀 DEFEATED! animation)
        ↓
showRestAndReward()
    (🏆 VICTORY! panel)
    - Heal to full HP
    - Gain XP
    - Check for level up
        ↓
Player presses SPACE or clicks
        ↓
dismissRewardPanel()
        ↓
prepareNextEncounter()
    - Increment room number
    - Generate new encounter
        ↓
Ready for next room!
```

## Key Differences

### Quick Rest (Between Monsters)
- ⚡️ **Quick Rest** branding
- Heals to full HP
- Shows next monster preview
- Same room/encounter continues
- Roll count resets to 0
- Shorter animations (0.5s defeat, 0.3s panel)

### Full Rest (Between Rooms/Encounters)
- 🏆 **VICTORY!** branding
- Heals to full HP
- Gains XP and checks for level up
- New encounter/room starts
- Room number increments
- Longer animations (1s defeat, 0.4s panel)
- More celebratory

## User Experience Improvements

1. **Clear Progression**: Player knows when they're fighting multiple monsters vs moving to a new room
2. **Strategic Rest**: Full heal between each monster prevents wear-down
3. **Preview System**: Shows what's coming next so player can prepare mentally
4. **Consistent Healing**: Full HP restoration prevents unfair difficulty spikes
5. **Proper Pacing**: Brief rest between monsters, longer celebration for rooms
6. **Visual Distinction**: Different colors/branding for quick rest vs full victory

## Technical Notes

- Both panel types use the same dismissal pattern (check for named node in input handlers)
- Quick rest panel is slightly smaller (450x200 vs 500x350)
- Green theme for rest (0.2, 0.4, 0.3) vs blue theme for rewards (0.2, 0.3, 0.4)
- Roll count resets for each monster, giving a fresh "first roll is free" each time
- Monster class instances are updated directly (reference type), so encounter tracking works correctly
