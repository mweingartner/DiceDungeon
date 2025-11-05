# Color Sequence Goal Debugging

## Issue
The "Red→Orange→Yellow→Green ascending" goal (and similar color sequence goals) don't seem to evaluate correctly.

## Code Analysis

### How Color Sequence Works

The `colorSequence` goal type checks if specific colored dice form a consecutive ascending sequence.

**Example**: `[.red, .orange, .yellow, .green]`
- Red must be some value N
- Orange must be N+1
- Yellow must be N+2
- Green must be N+3

**Valid examples:**
- Red=1, Orange=2, Yellow=3, Green=4 ✅
- Red=2, Orange=3, Yellow=4, Green=5 ✅
- Red=3, Orange=4, Yellow=5, Green=6 ✅

**Invalid examples:**
- Red=1, Orange=2, Yellow=3, Green=5 ❌ (Green should be 4)
- Red=2, Orange=2, Yellow=3, Green=4 ❌ (Orange should be 3)
- Red=1, Orange=3, Yellow=4, Green=5 ❌ (Orange should be 2)

## Logic Flow

### 1. Dice Results Collection
When player presses CHECK, `checkGoals()` collects all slotted dice:
```swift
var results: [DiceResult] = []
for i in 0..<6 {
    if let dice = slottedDice[i] {
        results.append(DiceResult(color: dice.color, value: dice.getValue()))
    }
}
```

**Important**: Results are in SLOT ORDER (0-5), not color order.

### 2. Goal Evaluation
For `colorSequence([.red, .orange, .yellow, .green])`:

```swift
// Extract values in the order specified by colors array
let colorValues = colors.compactMap { color in
    diceResults.first(where: { $0.color == color })?.value
}
// This reorders results to match the colors array!
```

**Example**:
- Slotted: [Green:4, Yellow:3, Orange:2, Red:1, Blue:5, Purple:6]
- Colors: [.red, .orange, .yellow, .green]
- colorValues: [1, 2, 3, 4] ← Extracted in colors array order

### 3. Consecutive Check
```swift
for i in 0..<(colorValues.count - 1) {
    if colorValues[i + 1] != colorValues[i] + 1 {
        return false  // Not consecutive
    }
}
```

Checks: 2==1+1? ✅, 3==2+1? ✅, 4==3+1? ✅ → SUCCESS

## Debugging Added

### In DiceGoal.swift
Added comprehensive logging to `colorSequence` case:
```swift
print("DEBUG colorSequence: Checking colors \(colors.map { $0.rawValue })")
for color in colors {
    if let result = diceResults.first(where: { $0.color == color }) {
        print("  \(color.rawValue): \(result.value)")
    } else {
        print("  \(color.rawValue): NOT FOUND")
    }
}
print("  colorValues array: \(colorValues)")
```

Shows:
- Which colors are being checked
- What value each color has (or NOT FOUND if missing)
- The final array of values to check

### In GameScene.swift
Enhanced `checkGoals()` logging:
```swift
print("DEBUG: Total results passed to goals: \(results.count)")
print("DEBUG: Results summary: \(results.map { "\($0.color.displayName):\($0.value)" }.joined(separator: ", "))")
```

Shows all dice that were slotted and their values.

## Testing Procedure

### Step 1: Encounter a Vampire
Vampire has: "Red→Orange→Yellow→Green ascending"

### Step 2: Roll and Slot Dice
Try to create a valid sequence, for example:
- Red die shows 2
- Orange die shows 3
- Yellow die shows 4
- Green die shows 5

Slot all four of these dice.

### Step 3: Press CHECK
Watch console output for:

```
DEBUG: Checking goals with 4 slotted dice
DEBUG: Slot 0: Red = 2
DEBUG: Slot 1: Orange = 3
DEBUG: Slot 2: Yellow = 4
DEBUG: Slot 3: Green = 5
DEBUG: Total results passed to goals: 4
DEBUG: Results summary: Red:2, Orange:3, Yellow:4, Green:5
DEBUG: Monster has 1 goals
DEBUG: Goal 0 'Red→Orange→Yellow→Green ascending' met: ???
DEBUG colorSequence: Checking colors ["red", "orange", "yellow", "green"]
  red: 2
  orange: 3
  yellow: 4
  green: 5
  colorValues array: [2, 3, 4, 5]
  SUCCESS: Valid ascending sequence!
```

If you see "FAILED" instead, the debug output will show WHY.

## Possible Issues

### Issue 1: Missing Dice
**Symptom**: "NOT FOUND" for one or more colors

**Cause**: Not all required colored dice are slotted

**Solution**: Must slot ALL four colors (Red, Orange, Yellow, Green)

### Issue 2: Not Consecutive
**Symptom**: "Values not consecutive - X then Y"

**Cause**: Values don't increment by exactly 1

**Example**: Red=1, Orange=2, Yellow=4, Green=5
- Debug shows: "Values not consecutive - 2 then 4"
- Need Yellow=3 to form 1,2,3,4,5

### Issue 3: Wrong Starting Value
**Symptom**: Goal works but seems arbitrary

**Cause**: Sequence can start at ANY value (1-3 for 4-dice sequence)

**Valid sequences**:
- 1→2→3→4 ✅
- 2→3→4→5 ✅  
- 3→4→5→6 ✅

### Issue 4: Extra Dice Slotted
**Symptom**: Goal doesn't evaluate

**Cause**: Having extra colors slotted shouldn't matter

**Expected**: Code only looks at the 4 required colors, ignores others

## Expected Console Output Examples

### ✅ Success Case
```
DEBUG colorSequence: Checking colors ["red", "orange", "yellow", "green"]
  red: 1
  orange: 2
  yellow: 3
  green: 4
  colorValues array: [1, 2, 3, 4]
  SUCCESS: Valid ascending sequence!
```

### ❌ Failure Case - Missing Color
```
DEBUG colorSequence: Checking colors ["red", "orange", "yellow", "green"]
  red: 1
  orange: 2
  yellow: 3
  green: NOT FOUND
  FAILED: Not all colors found (3 vs 4)
```

### ❌ Failure Case - Not Consecutive
```
DEBUG colorSequence: Checking colors ["red", "orange", "yellow", "green"]
  red: 1
  orange: 3
  yellow: 4
  green: 5
  colorValues array: [1, 3, 4, 5]
  FAILED: Values not consecutive - 1 then 3
```

## If Goal Still Doesn't Work

Check these scenarios:

1. **Are all 4 colors slotted?** (Red, Orange, Yellow, Green)
2. **Do they form consecutive values?** (e.g., 2,3,4,5 not 2,3,5,6)
3. **Is it the right monster?** (Vampire has this goal)
4. **Has goal already been completed?** (Goals can only be completed once)

## Alternative Solution: Relax Requirements

If the goal is too strict, we could change it to just check "ascending" (not necessarily consecutive):

```swift
// Instead of: colorValues[i + 1] != colorValues[i] + 1
// Use: colorValues[i + 1] <= colorValues[i]  // Just check increasing

for i in 0..<(colorValues.count - 1) {
    if colorValues[i + 1] <= colorValues[i] {  // Must be strictly increasing
        return false
    }
}
```

This would allow: 1,3,5,6 or 2,4,5,6 (not just 1,2,3,4).

But the current implementation matches the description "ascending" as consecutive values, which is standard for sequence-based goals.

## Next Steps

1. Run the game
2. Encounter a Vampire (or Skeleton which has 3-color version)
3. Try the goal with proper values
4. Share the console output
5. We can diagnose the exact issue from the debug logs
