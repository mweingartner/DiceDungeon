# High Score Leaderboard Debugging

## Issue
The high score leaderboard is not showing high scores on screen.

## Changes Made for Debugging

### 1. Added Debug Logging

#### HighScore.swift
- **loadScores()**: Now prints file path, whether file exists, number of scores loaded, and any errors
- **addScore()**: Prints when adding a score with details (initials, XP, room)
- **isHighScore()**: Prints logic for determining if a score qualifies, including comparison values

#### GameScene.swift
- **setupUI()**: Prints when creating each leaderboard label and its position
- **updateLeaderboard()**: Prints each label text being set
- **handleGameEnd()**: Prints when game ends, player XP, whether score qualifies

### 2. Fixed Empty Leaderboard Display

**Before:**
```swift
label.text = ""  // Labels started empty
```

**After:**
```swift
label.text = String(format: "%2d. --- ----", i + 1)  // Show placeholder immediately
```

**Impact**: Now you should see "1. --- ----" through "10. --- ----" even with no scores, confirming the leaderboard is visible.

## How to Test

### Step 1: Verify Leaderboard is Visible
1. Launch the game
2. Look for "🏆 TOP SCORES 🏆" in yellow on the left side
3. You should see entries like:
   ```
   1. --- ----
   2. --- ----
   ...
   10. --- ----
   ```

If you DON'T see these, the issue is positioning/visibility, not data.

### Step 2: Check Console Output
When you start the game, you should see:
```
DEBUG setupUI: Creating leaderboard label [0] at position ...
DEBUG setupUI: Creating leaderboard label [1] at position ...
...
DEBUG setupUI: Loading high scores...
DEBUG HighScoreManager: Attempting to load scores from: /path/to/highscores.json
DEBUG HighScoreManager: No high scores file found, returning empty array (OR)
DEBUG HighScoreManager: Loaded X scores successfully
DEBUG setupUI: Loaded X scores, updating leaderboard...
DEBUG updateLeaderboard: Called with X high scores
DEBUG updateLeaderboard: [0] Setting empty: 1. --- ----
...
DEBUG updateLeaderboard: Leaderboard update complete
```

### Step 3: Die in Game and Check Score Entry
1. Play until you die (or intentionally take damage)
2. Watch console:
   ```
   DEBUG handleGameEnd: Player died with X XP, Room Y
   DEBUG handleGameEnd: Current high scores count: Z
   DEBUG isHighScore: Checking XP X against Z existing scores
   DEBUG isHighScore: Board not full (Z/10), qualifies!
   DEBUG handleGameEnd: Qualifies for high score: true
   DEBUG handleGameEnd: Showing initials entry dialog
   ```

3. Enter your initials (3 letters)
4. Press Return
5. Watch console:
   ```
   DEBUG HighScoreManager: Adding score - ABC: X XP, Room Y
   DEBUG HighScoreManager: Attempting to load scores from: /path/to/highscores.json
   DEBUG HighScoreManager: Saving X total scores
   High scores saved to: /path/to/highscores.json
   DEBUG HighScoreManager: Attempting to load scores from: /path/to/highscores.json
   DEBUG HighScoreManager: Loaded X scores successfully
   DEBUG updateLeaderboard: Called with X high scores
   DEBUG updateLeaderboard: [0] Setting: 1. ABC  100XP R5
   ```

### Step 4: Verify Leaderboard Shows Score
After entering initials, you should see your score on the leaderboard:
```
1. ABC  100XP R5
2. --- ----
3. --- ----
...
```

## Common Issues and Solutions

### Issue: Leaderboard Not Visible At All
**Symptoms**: Can't see "🏆 TOP SCORES 🏆" or any "--- ----" entries

**Possible Causes**:
1. **Label position is off-screen**
   - Check: `Layout.leaderboardYOffset = 207`
   - Try: Reduce to `Layout.leaderboardYOffset = 150` to move up
   
2. **Window too small**
   - Check: Window is at least 800x600
   - Try: Maximize window

3. **Labels not being added to scene**
   - Check console for: "DEBUG setupUI: Created leaderboard label"
   - If missing, there's a code execution issue

### Issue: Shows "--- ----" But Not Real Scores
**Symptoms**: Placeholder text shows, but scores don't replace it

**Check**:
1. Console shows "Loaded 0 scores" → No scores saved yet (need to die first)
2. Console shows "Loaded X scores" but updateLeaderboard not called
3. Console shows errors loading JSON

**Solution**: Try dying and entering initials to create first score

### Issue: Initials Dialog Doesn't Appear
**Symptoms**: Game over happens but no dialog to enter initials

**Check Console**:
- "DEBUG handleGameEnd: Qualifies for high score: false" → XP was 0 or very low
- Try playing longer to gain XP before dying

### Issue: Score Entered But Not Showing
**Symptoms**: Dialog works, but score doesn't appear on leaderboard

**Check**:
1. Console for "High scores saved to:" message
2. Check file exists at that path
3. Console for errors loading or saving JSON
4. Console for "DEBUG updateLeaderboard: Called with X" where X > 0

## File Location

High scores are saved to:
```
~/Documents/highscores.json
```

You can:
- **View the file** in Finder or terminal
- **Delete the file** to reset all scores
- **Edit the file** to add test data (be careful with JSON format)

## Test Data

To quickly test, you can create a `highscores.json` file manually:

```json
[
  {
    "initials" : "ABC",
    "xp" : 500,
    "roomNumber" : 10,
    "date" : "2025-11-05T12:00:00Z"
  },
  {
    "initials" : "XYZ",
    "xp" : 300,
    "roomNumber" : 7,
    "date" : "2025-11-05T11:00:00Z"
  }
]
```

Save this to `~/Documents/highscores.json` and restart the game.

## Next Steps

1. **Run the game** and check console output
2. **Look for the leaderboard** on screen (left side, below player XP)
3. **Report what you see**:
   - Is "🏆 TOP SCORES 🏆" visible?
   - Do you see "1. --- ----" entries?
   - What does the console say when game starts?
   - What happens when you die?

This will help identify whether it's a visibility issue, data loading issue, or update issue.
