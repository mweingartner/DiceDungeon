# Character Image Implementation

## Summary
Added 256x256 player and monster images to the game interface.

## Changes Made

### 1. Added Image Node Properties
- `playerImageNode: SKSpriteNode!` - Displays player.png
- `monsterImageNode: SKSpriteNode!` - Displays current monster image

### 2. Layout Constants
- `characterImageSize: CGFloat = 256` - Size for both images
- `characterImageFromBottom: CGFloat = 256` - Position from bottom of screen (lower third)

### 3. Image Setup in setupUI()
**Player Image (Left Side):**
- Positioned at: `Layout.padding + characterImageSize / 2` from left edge
- Y position: `Layout.characterImageFromBottom` (256 pixels from bottom - in lower third of screen)
- Always displays "player" asset

**Monster Image (Right Side):**
- Positioned at: `size.width - Layout.padding - characterImageSize / 2` from right edge
- Y position: `Layout.characterImageFromBottom` (same as player - 256 pixels from bottom)
- Dynamically updates based on current monster

### 4. Dynamic Monster Image Updates
Created `updateMonsterImage()` method that:
- Gets current monster from encounter
- Loads image named `{monsterType}.png` (e.g., "slime.png", "dragon.png")
- Updates or creates the monster sprite node
- Hides image when no monster is present

The method is called from `updateUI()`, ensuring the monster image updates:
- When a new encounter starts
- When transitioning between monsters
- When the scene is resized
- After completing a monster

## Image File Requirements

### Player Image
- **Asset Name:** `player` (no file extension)
- **Size:** Should be at least 256x256 pixels
- **Location:** In the project's Asset Catalog (Assets.xcassets)

### Monster Images
Required monster image asset names (matching MonsterType.rawValue):
- `slime`
- `rat`
- `spider`
- `bat`
- `goblin`
- `skeleton`
- `zombie`
- `orc`
- `ghost`
- `troll`
- `vampire`
- `werewolf`
- `demon`
- `dragon`
- `lich`
- `hydra`

All monster images should be at least 256x256 pixels for best quality.
All images should be added to the Asset Catalog (Assets.xcassets) without file extensions.

## Layout
```
┌─────────────────────────────────────────────────────────────────┐
│                     ⚔️ Dice Dungeon ⚔️                          │
│                                                                 │
│  ❤️ HP: X/X                              Monster Name 👹       │
│  ⭐️ XP: XXX | Level: X                  Goals: X/X             │
│                                                                 │
│  🏆 TOP SCORES 🏆                        Goals to complete:    │
│  1. ABC 1234XP R5                         • Goal description   │
│  2. XYZ 1100XP R4                         • Goal description   │
│  ...                                                            │
│                                                                 │
│                                                                 │
│                    [Dice Area]                                  │
│                                                                 │
│                    [Buttons]                                    │
│                                                                 │
│  ┌──────────┐                            ┌──────────┐          │
│  │          │                            │          │          │
│  │  Player  │                            │ Monster  │          │
│  │  Image   │                            │  Image   │          │
│  │ 256x256  │                            │ 256x256  │          │
│  └──────────┘                            └──────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

## Notes
- Images maintain aspect ratio within the 256x256 size constraint
- Images are now loaded from the Asset Catalog (Assets.xcassets)
- Asset names do not include file extensions (e.g., "player" not "player.png")
- SpriteKit automatically handles missing images with a warning
- The monster image updates automatically during gameplay
- Player image remains constant throughout the game
