# Centered Three-Button Layout Fix

## Problem
The Check and Run buttons were overlapping because the spacing calculation wasn't properly accounting for three buttons.

## Solution
Implemented a proper centered layout that:
1. Calculates the total width needed for 3 buttons with gaps
2. Centers the entire button group on the screen
3. Spaces buttons evenly with equal gaps

## Layout Calculation

### Key Variables
```swift
let buttonSpacingFor3 = Layout.buttonWidth + 40  // Button width + 40pt gap
let totalWidth = buttonSpacingFor3 * 2           // Width for 3 buttons (2 gaps)
let startX = (size.width - totalWidth) / 2       // Starting X to center the group
```

### Button Positions
- **Roll button**: `startX` (leftmost)
- **Check button**: `startX + buttonSpacingFor3` (middle)
- **Run button**: `startX + buttonSpacingFor3 * 2` (rightmost)

## Visual Layout

### Before (Overlapping):
```
        [ROLL]   [CHECK][RUN]
                   ↑↑ Overlap!
```

### After (Properly Centered):
```
    [ROLL DICE]    [CHECK]    [🏃 RUN]
    ←40pt gap→     ←40pt gap→
    ←────── Centered on screen ──────→
```

## Spacing Details

With `Layout.buttonWidth = 180`:
- **buttonSpacingFor3** = 180 + 40 = 220 pixels
- **totalWidth** = 220 × 2 = 440 pixels (for 3 buttons)
- **Gap between buttons** = 40 pixels

Example on 800px wide screen:
- startX = (800 - 440) / 2 = 180
- Roll: x = 180
- Check: x = 180 + 220 = 400
- Run: x = 180 + 440 = 620

## Benefits

1. ✅ **No overlap** - Proper spacing calculation prevents overlap
2. ✅ **Centered group** - All three buttons centered as a unit
3. ✅ **Equal spacing** - Consistent 40px gaps between buttons
4. ✅ **Responsive** - Automatically adjusts to screen width
5. ✅ **Clean appearance** - Professional, balanced layout

## How It Works

Instead of using fixed offsets from center (`size.width / 2 ± spacing`), the new code:

1. **Calculates total space needed**: 
   - 3 buttons × button width
   - 2 gaps × gap size
   
2. **Centers the group**:
   - Finds starting X position to center all buttons as one unit
   
3. **Positions each button**:
   - Each button positioned relative to `startX`
   - Evenly spaced using `buttonSpacingFor3`

## Customization

To adjust spacing between buttons, change the gap value:
```swift
let buttonSpacingFor3 = Layout.buttonWidth + 40  // Change 40 to desired gap
```

- Smaller value (e.g., 20) = buttons closer together
- Larger value (e.g., 60) = buttons farther apart

## Testing

Test on different window sizes to ensure:
- ✅ Buttons stay centered as window resizes
- ✅ No buttons go off-screen
- ✅ Equal spacing maintained
- ✅ All three buttons remain clickable

Minimum recommended window width: 800px (matches Layout.minWidth)
