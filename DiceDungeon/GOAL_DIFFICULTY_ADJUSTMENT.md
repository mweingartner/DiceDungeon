# Monster Goal Difficulty Adjustment

## Overview
Adjusted monster goals to be more achievable while maintaining challenge progression. Ensured all classic Yahtzee-style roll combinations are included in the goal options.

## Changes Made

### Difficulty Reductions

#### Medium Monsters

**Goblin**
- Before: "Red, Yellow & Green all even" (3 colors)
- After: "Red & Yellow both even" (2 colors)
- Extra goal requirement: 5+ → 4+

**Zombie**
- Before: "Red, Green & Blue all match" (3-way color match)
- After: "Red & Green match" (2-way pair)
- Sum requirement: 15+ → 12+

#### Hard Monsters

**Troll**
- Sum requirement: 16+ → 13+

**Vampire**
- Removed: "Red die shows 6" (exact requirement)
- Added: "Small straight" (more achievable)
- Extra goal: Full house instead of large straight

**Werewolf**  
- Removed: "Five of a kind" (very rare)
- Added: "Four of a kind" (more reasonable)
- Color odds: 3 colors → 2 colors

**Demon**
- Removed: Color sum requirement (17+)
- Added: "Four of a kind" as primary goal
- Extra goals: Full house and large straight instead of color triple

#### Boss Monsters

**Dragon**
- Removed: "Rainbow pattern" (extremely difficult)
- Added: "Large straight" (challenging but achievable)
- Removed: "Full straight" from extra goals
- Removed: "Red shows 6" exact requirement

**Lich**
- Removed: "Six of a kind" (nearly impossible)
- Added: "Five of a kind (Yahtzee!)" (still hard but possible)
- Removed: Complex color sequence
- Kept: All cool colors 4+ (challenging but fair)

**Hydra**
- Removed: "Rainbow pattern" (extremely difficult)
- Added: "Full straight" (rare but clear goal)
- Sum requirement: 17+ → 14+
- Extra goals: Four of a kind + Full house instead of color triple

## Yahtzee-Style Combinations Included

### ✅ All Standard Yahtzee Patterns Available

1. **Pair** ✅
   - Two dice showing the same number
   - Used in: Slime, Rat (extra goals)

2. **Two Pair** ✅
   - Two different pairs
   - Used in: Spider, Ghost (extra goals)

3. **Three of a Kind** ✅
   - Three dice showing the same number
   - Used in: Bat, Goblin, Zombie (extra goals)

4. **Four of a Kind** ✅
   - Four dice showing the same number
   - Used in: Troll, Werewolf, Demon, Dragon, Hydra

5. **Five of a Kind (Yahtzee)** ✅
   - Five dice showing the same number
   - Used in: Lich (extra goal)
   - Description: "Roll five of a kind (Yahtzee!)"

6. **Six of a Kind** ✅
   - All six dice showing the same number
   - Available in DiceGoal.swift but NOT used in monsters (too rare)

7. **Full House** ✅
   - Three of one number + two of another
   - Used in: Skeleton, Vampire, Demon, Lich, Hydra

8. **Small Straight** ✅
   - Four consecutive numbers (e.g., 1-2-3-4 or 3-4-5-6)
   - Used in: Orc, Vampire
   - Description: "Roll a small straight (4 consecutive)"

9. **Large Straight** ✅
   - Five consecutive numbers (e.g., 1-2-3-4-5 or 2-3-4-5-6)
   - Used in: Demon, Dragon, Lich
   - Description: "Roll a large straight (5 consecutive)"

10. **Full Straight** ✅
    - All six numbers 1-2-3-4-5-6
    - Used in: Hydra (boss only)
    - Description: "Roll 1-6 straight"

### Additional Goal Types (Color-Based)

Beyond standard Yahtzee, the game includes:
- Color matching (specific dice show specific values)
- Color pairs/triples (multiple colors match values)
- Color sums (specific dice sum to threshold)
- Color sequences (specific dice form ascending pattern)
- Warm/cool color requirements
- Odd/even requirements on specific colors

## Difficulty Comparison

### Before
- **Medium**: 3-5 difficulty ratings, multi-color exact matches
- **Hard**: 6-8 difficulty ratings, 5-of-a-kind, high sums (17+)
- **Boss**: 9-10 difficulty ratings, rainbow patterns, 6-of-a-kind, exact color requirements

### After
- **Medium**: 2-4 difficulty ratings, 2-color matches, achievable sums
- **Hard**: 5-7 difficulty ratings, 4-of-a-kind, moderate sums (13-14+)
- **Boss**: 6-8 difficulty ratings, straights, full houses, 5-of-a-kind

## Probability Improvements

### Examples of Improved Odds

**Three-color even requirement → Two-color even:**
- Before: (1/2)³ = 12.5% per roll
- After: (1/2)² = 25% per roll
- **2x easier**

**Sum 17+ → Sum 13+ (3 dice):**
- Before: Very few combinations
- After: Many more valid combinations
- **~3-4x easier**

**Five of a kind → Four of a kind:**
- Before: 6/7776 ≈ 0.08% per roll
- After: 150/7776 ≈ 1.93% per roll
- **~25x easier**

**Six of a kind (removed):**
- Probability: 6/46656 ≈ 0.01% per roll
- **Too rare for fair gameplay**

## Removed Overly Difficult Goals

1. **Rainbow Pattern** ❌
   - Required: All adjacent color pairs differ by exactly 1
   - Too complex and restrictive
   
2. **Six of a Kind** ❌
   - Probability too low for reasonable gameplay
   
3. **Exact Color Requirements (value 6)** ❌
   - Changed to 4+ or 5+ (minimum requirements)
   
4. **Three-Color Exact Matches** ❌
   - Reduced to two-color matches
   
5. **Very High Sum Requirements (17+)** ❌
   - Reduced to 12-15 range

## Progression Balance

### Room 1-3 (Easy Monsters)
- Single simple goal (pair, color match 3+)
- +1 goal per 50% difficulty increase

### Room 4-7 (Medium Monsters)
- 1-2 achievable goals (two pair, three of a kind, color combinations)
- Focus on pattern recognition

### Room 8-12 (Hard Monsters)  
- 2-3 moderate goals (four of a kind, straights, color requirements)
- Requires strategic dice placement

### Room 13+ (Boss Monsters)
- 2-4 challenging goals (full house, large straight, five of a kind)
- Tests mastery of dice combinations

## Testing Recommendations

1. Play through rooms 8-15 to verify difficulty curve
2. Check that hard monsters are beatable within reasonable rolls
3. Verify boss monsters are challenging but fair
4. Confirm all Yahtzee patterns appear in gameplay
5. Test that color-based goals are clear and achievable

## Summary

- ✅ **Reduced difficulty** on medium-hard monsters
- ✅ **Toned down** sum requirements by 2-4 points
- ✅ **Replaced** impossible goals with challenging but fair ones
- ✅ **Included** all 10 standard Yahtzee patterns
- ✅ **Removed** overly rare combinations (6-of-a-kind, rainbow pattern)
- ✅ **Maintained** progression from simple to complex
- ✅ **Preserved** variety through color-based mechanics

The game should now feel more balanced and achievable while still providing increasing challenge as players progress through rooms.
