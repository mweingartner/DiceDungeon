//
//  RESPONSIVE_UI_CHANGES.md
//  DiceDungeon
//
//  Responsive UI Implementation Documentation
//

# Responsive UI Changes for GameScene

## Overview
Implemented dynamic sizing and positioning for all GameScene UI elements to properly handle window resizing and different window sizes. All elements now scale proportionally based on the scene's dimensions.

## Changes Made

### 1. Layout Constants Structure
Added a `Layout` struct with constants that define relative positioning:
```swift
private struct Layout {
    static let minWidth: CGFloat = 800
    static let minHeight: CGFloat = 600
    static let padding: CGFloat = 20
    static let titleYOffset: CGFloat = 60
    static let roomYOffset: CGFloat = 100
    static let rollCountYOffset: CGFloat = 130
    static let playerStatsYOffset: CGFloat = 60
    static let playerXPYOffset: CGFloat = 90
    static let monsterStatsYOffset: CGFloat = 60
    static let monsterHPYOffset: CGFloat = 90
    static let goalsYOffset: CGFloat = 170
    static let buttonYOffset: CGFloat = 80
    static let resultYOffset: CGFloat = 160
    static let buttonWidth: CGFloat = 180
    static let buttonHeight: CGFloat = 60
    static let buttonSpacing: CGFloat = 100
}
```

### 2. Dynamic Font Sizing
All font sizes now scale based on scene width:
- **Title**: `min(48, sceneWidth / 20)` - Scales from 48px down for smaller windows
- **Large text**: `min(28, sceneWidth / 30)` - Player/Monster HP
- **Medium text**: `min(24, sceneWidth / 35)` - Room number
- **Normal text**: `min(20, sceneWidth / 40)` - XP, Monster HP details
- **Small text**: `min(18, sceneWidth / 45)` - Goals, continue prompts

### 3. Responsive UI Elements

#### Header Elements
- **Title**: Centered at top, font scales with window width
- **Room Number**: Below title, centered
- **Roll Count**: Below room number, centered
- **Player Stats**: Left side with padding, font scales
- **Monster Stats**: Right side with padding, font scales
- **Goals Label**: Centered below stats, width adjusts with `preferredMaxLayoutWidth`

#### Interactive Elements
- **Roll/Check Buttons**: Fixed size (180x60) positioned relative to center
- **Result Label**: Centered above buttons, width adjusts dynamically

#### Dice and Slots
- **Dice Spacing**: Scales with scene width (`min(110, sceneWidth / 8)`)
- **Dice Rows**: Positioned relative to center with proportional spacing
- **Slot Size**: Scales with scene width (`min(90, sceneWidth / 10)`)
- **Slot Spacing**: Scales with scene width (`min(100, sceneWidth / 9)`)
- **Slot Position**: Positioned below center with responsive offset

### 4. Modal Panels

#### Reward Panel (Room Complete)
- **Panel Size**: `min(500, size.width * 0.7)` x `min(350, size.height * 0.5)`
- **Font Sizes**: Scale proportionally with panel width
- **Content Positioning**: Relative to panel dimensions (percentages)

#### Rest Panel (Between Monsters)
- **Panel Size**: `min(450, size.width * 0.6)` x `min(200, size.height * 0.33)`
- **Font Sizes**: Scale proportionally with panel width
- **Content Positioning**: Relative to panel dimensions (percentages)

#### Defeat Animation Labels
- **Font Size**: `min(64, size.width / 15)` for full encounter
- **Font Size**: `min(48, size.width / 20)` for individual monsters

### 5. Window Resize Behavior
The existing `didChangeSize(_:)` method already handles window resizing by:
1. Removing all children
2. Clearing dice and slot arrays
3. Preserving game state (player, encounter, roll count)
4. Recreating all UI with new dimensions

## Benefits

1. **Scalability**: Works well on different screen sizes and aspect ratios
2. **Consistency**: All elements maintain proportional relationships
3. **Readability**: Text remains readable at all window sizes with minimum constraints
4. **Layout Integrity**: Elements stay properly positioned and spaced
5. **No Clipping**: Content adjusts to available space with `preferredMaxLayoutWidth`

## Testing Recommendations

1. Test with minimum window size (800x600)
2. Test with large window sizes (1920x1080+)
3. Test dynamic resizing during gameplay
4. Verify all modals display correctly at different sizes
5. Ensure dice and slots remain clickable and properly positioned
6. Check text doesn't overflow or clip at any size

## Future Enhancements

Potential improvements for even better responsiveness:
1. Adjust dice size (`DiceNode.diceSize`) based on available space
2. Implement different layouts for extremely wide or tall aspect ratios
3. Add minimum window size enforcement at the application level
4. Consider tablet/mobile-friendly layouts for potential iOS port
