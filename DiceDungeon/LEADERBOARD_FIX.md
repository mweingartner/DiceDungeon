# High Score Leaderboard Update Issue - Fix

## Problem
The high score leaderboard shows the "🏆 TOP SCORES 🏆" title and placeholder entries, the initials dialog appears and works, but the leaderboard never updates with the new scores after submission.

## Root Cause Identified

### Missing Date Decoding Strategy
The most likely cause is in `HighScore.swift` - the `loadScores()` function was missing the date decoding strategy:

**Before:**
```swift
let scores = try JSONDecoder().decode([HighScore].self, from: data)
```

**After:**
```swift
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601  // <- THIS WAS MISSING!
let scores = try decoder.decode([HighScore].self, from: data)
```

### Why This Matters
- When saving scores, we use: `encoder.dateEncodingStrategy = .iso8601`
- But when loading, the decoder was using the default strategy
- This mismatch causes JSON decoding to fail
- The error was caught but silently returned an empty array
- Result: Scores were being saved but couldn't be loaded back

## Additional Debugging Added

### 1. Enhanced Load Logging
Now prints:
- Bytes read from file
- Each score loaded with details
- Number of sorted scores returned
- Detailed error information if decoding fails

### 2. Enhanced Update Logging
`updateLeaderboard()` now checks:
- If labels still have a parent (are in the scene)
- Warns if labels were removed
- Logs leaderboardLabels.count

### 3. Enhanced Dismiss Logging
`dismissInitialsDialog()` now shows:
- When it's called and with what data
- Step-by-step progress through the function
- Array counts to verify data flow

## How to Test the Fix

### 1. Delete Old High Scores File
The old file might be corrupted or in wrong format:
```bash
rm ~/Documents/highscores.json
```

### 2. Run the Game and Check Console
Start game and look for:
```
DEBUG setupUI: Loading high scores...
DEBUG HighScoreManager: Attempting to load scores from: /Users/.../Documents/highscores.json
DEBUG HighScoreManager: No high scores file found, returning empty array
DEBUG setupUI: Loaded 0 scores, updating leaderboard...
```

### 3. Play and Die
Let the game progress, then die (or take damage until HP = 0)

### 4. Enter Initials
When dialog appears:
- Type 3 letters (e.g., "ABC")
- Press Return

### 5. Watch Console for Success
Should see:
```
DEBUG dismissInitialsDialog: Called with initials=ABC, xp=100, room=5
DEBUG dismissInitialsDialog: Saving score...
DEBUG HighScoreManager: Adding score - ABC: 100 XP, Room 5
DEBUG HighScoreManager: Attempting to load scores from: ...
DEBUG HighScoreManager: Loaded 0 scores successfully
DEBUG HighScoreManager: Saving 1 total scores
High scores saved to: /Users/.../Documents/highscores.json
DEBUG dismissInitialsDialog: Reloading scores...
DEBUG HighScoreManager: Attempting to load scores from: ...
DEBUG HighScoreManager: Read 185 bytes from file
DEBUG HighScoreManager: Decoded 1 scores successfully
  Score 0: ABC - 100 XP, Room 5
DEBUG HighScoreManager: Returning 1 sorted scores
DEBUG dismissInitialsDialog: Loaded 1 scores
DEBUG dismissInitialsDialog: leaderboardLabels.count = 10
DEBUG dismissInitialsDialog: Calling updateLeaderboard()...
DEBUG updateLeaderboard: Called with 1 high scores
DEBUG updateLeaderboard: leaderboardLabels.count = 10
DEBUG updateLeaderboard: [0] Setting: 1. ABC  100XP R5
DEBUG updateLeaderboard: [1] Setting empty: 2. --- ----
...
DEBUG updateLeaderboard: Leaderboard update complete
DEBUG dismissInitialsDialog: updateLeaderboard() complete
DEBUG dismissInitialsDialog: Complete
```

### 6. Verify on Screen
Look at left side of screen - should now show:
```
🏆 TOP SCORES 🏆
 1. ABC  100XP R5
 2. --- ----
 3. --- ----
...
10. --- ----
```

## If Still Not Working

### Check Console for Errors
Look for:
```
ERROR HighScoreManager: Failed to load high scores: ...
WARNING updateLeaderboard: Label [X] has no parent! It was removed from scene.
```

### Error: "Failed to load high scores"
**Cause**: JSON decoding still failing
**Check**:
1. Look at the file: `cat ~/Documents/highscores.json`
2. Verify JSON format is correct
3. Check error details in console

### Warning: "Label has no parent"
**Cause**: Window was resized and labels were removed
**Solution**: This is expected if window resizes. Labels should be recreated automatically.

### Scores Save But Don't Show
**Check**:
1. Console shows "Decoded X scores successfully"?
2. Console shows "Setting: 1. ABC ..."?
3. If yes to both but still not visible → positioning issue

### Positioning Check
Try adjusting in GameScene.swift:
```swift
static let leaderboardYOffset: CGFloat = 150  // Try lower value
```

## Manual Test with JSON File

Create `~/Documents/highscores.json` manually:
```json
[
  {
    "initials" : "TST",
    "xp" : 500,
    "roomNumber" : 10,
    "date" : "2025-11-05T12:00:00Z"
  },
  {
    "initials" : "QQQ",
    "xp" : 250,
    "roomNumber" : 7,
    "date" : "2025-11-05T11:00:00Z"
  }
]
```

Start game and check if these appear. If they do, the fix worked!

## Expected Behavior After Fix

1. ✅ Game starts → Placeholder scores visible
2. ✅ Player dies → Initials dialog appears
3. ✅ Enter initials → Score saves to file
4. ✅ After submit → Score loads from file
5. ✅ Leaderboard updates → Score appears on screen
6. ✅ New game → Scores persist from file
7. ✅ Multiple scores → Sorted by XP (highest first)
8. ✅ More than 10 scores → Only top 10 kept

## Summary

The fix was simple but critical: **adding the matching date decoding strategy**. The encoder and decoder must use the same strategy for the date field, or JSON decoding silently fails and returns empty arrays.

With the enhanced logging, you'll now see exactly where any issues occur, making it much easier to diagnose problems.
