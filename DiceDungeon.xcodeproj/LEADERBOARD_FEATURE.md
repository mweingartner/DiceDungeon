# Leaderboard Feature Implementation

## Overview
Added a comprehensive high score leaderboard system to Dice Dungeon that tracks the top 10 scores by XP earned during each dungeon run. Players can enter their 3-letter initials when they achieve a high score, and the scores persist between game sessions.

## New Files Created

### HighScore.swift
- **HighScore struct**: Codable struct that stores score data
  - `initials`: 3-letter player identifier
  - `xp`: Experience points earned
  - `roomNumber`: How far the player progressed
  - `date`: When the score was achieved
  - Implements `Comparable` to sort by XP (highest first)

- **HighScoreManager class**: Singleton manager for score persistence
  - Loads/saves scores to JSON file in Documents directory
  - Maintains top 10 scores automatically
  - Provides `isHighScore()` to check if a score qualifies
  - Uses pretty-printed JSON format for readability

## Changes to GameScene.swift

### New Properties
- `leaderboardTitleLabel`: Title label for leaderboard section
- `leaderboardLabels`: Array of 10 labels to display scores
- `highScores`: Array of loaded high scores

### Layout Updates
Added new layout constants:
- `leaderboardYOffset`: Position of leaderboard title (135 points from top)
- `leaderboardLineHeight`: Spacing between entries (20 points)

### UI Setup (setupUI)
Added leaderboard display on left side below player stats:
- Title: "🏆 TOP SCORES 🏆" in yellow/gold color
- 10 score entries showing: rank, initials, XP, and room number
- Format: `"1. ABC  250XP R15"`
- Empty slots show as: `"5. --- ----"`
- Uses monospaced Courier font for alignment
- All text in yellow color (RGB: 1.0, 0.84, 0.0)

### New Functions

#### updateLeaderboard()
Updates the leaderboard display with current high scores. Shows rank, initials, XP, and room number in a formatted string.

#### handleGameEnd()
Called when player dies:
- Checks if score qualifies for leaderboard
- Shows initials entry dialog if it's a high score
- Otherwise shows standard game over message

#### showInitialsEntryDialog(xp:roomNumber:)
Creates and displays modal dialog for entering initials:
- Semi-transparent black overlay
- Gold-bordered panel with title "🏆 HIGH SCORE! 🏆"
- Shows score achieved (XP and room number)
- Interactive 3-character input field showing "___"
- Instructions for keyboard input
- Disables game buttons during entry
- Stores XP and room data in panel's userData

#### dismissInitialsDialog(initials:xp:roomNumber:)
Handles completion of initials entry:
- Saves score to HighScoreManager
- Reloads and updates leaderboard display
- Removes dialog and overlay
- Re-enables game buttons
- Shows completion message

### Updated Functions

#### didMove(to:) and didChangeSize(_:)
- Load high scores at startup
- Update leaderboard display

#### startNewGame()
- Clears any existing initials dialog
- Resets newGameButton alpha to 1.0

#### updateUI()
Modified player death handling:
- Shows score in final message (XP instead of just level)
- Triggers handleGameEnd() after 1 second delay
- Prevents multiple dialogs from showing

#### keyDown(with:)
Added keyboard handling for initials entry dialog:
- **Letter keys (A-Z)**: Add character to initials (max 3)
- **Backspace/Delete**: Remove last character
- **Return/Enter**: Submit initials (only when 3 characters entered)
- Characters are automatically uppercased
- Display updates in real-time as "___" → "A__" → "AB_" → "ABC"

## User Experience

### High Score Entry Flow
1. Player's health reaches 0
2. Brief "You have been defeated!" message appears
3. After 1 second, if score qualifies:
   - Modal dialog appears with score information
   - Player types 3 letters for their initials
   - Player presses Return to submit
4. Score is saved and leaderboard updates
5. "NEW GAME" button is available to restart

### Visual Design
- **Leaderboard colors**: Gold/yellow theme (RGB: 1.0, 0.84, 0.0)
- **Position**: Left side, below player HP and XP
- **Alignment**: Left-aligned with consistent spacing
- **Format**: Monospaced font for clean column alignment
- **Dialog**: Dark blue panel with gold border, centered on screen

### Data Persistence
- Scores saved to `highscores.json` in user's Documents directory
- JSON format with pretty printing for readability
- ISO8601 date encoding
- Automatically loads on game start
- Survives app restarts

## Technical Details

### File Storage
- Location: `~/Documents/highscores.json`
- Format: Pretty-printed JSON array
- Fields per score: initials, xp, roomNumber, date

### Score Qualification
A score qualifies for the leaderboard if:
- Fewer than 10 scores exist, OR
- New score XP > lowest current score XP

### Keyboard Input Handling
- Only accepts letter characters (A-Z)
- Automatically converts to uppercase
- Prevents more than 3 characters
- Visual feedback with underscore placeholders

## Future Enhancements (Optional)
- Add date display in leaderboard
- Add "clear all scores" option
- Add difficulty modifiers
- Add online leaderboards
- Add more statistics (monsters defeated, rooms cleared, etc.)
