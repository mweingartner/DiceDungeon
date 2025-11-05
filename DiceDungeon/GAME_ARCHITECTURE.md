//
//  GAME_ARCHITECTURE.md
//  DiceDungeon
//
//  Game Architecture Documentation
//

# Dice Dungeon - Game Architecture

## Overview
Dice Dungeon is a turn-based dungeon crawler where the player fights progressively harder monsters using colored dice rolls.

## Core Systems

### 1. Player System (Player.swift)
- **Starting HP**: 50
- **Max HP**: Increases by 10 per level
- **Experience**: Gained from defeating monsters
- **Level**: Increases every 100 XP
- **Healing**: Heals after completing each room
- **Death**: Game ends when HP reaches 0

### 2. Dice System (DiceColor.swift, GameScene.swift - DiceNode)
Six colored dice representing the rainbow:
1. Red
2. Orange
3. Yellow
4. Green
5. Blue
6. Purple

Each die:
- Shows values 1-6
- Has a unique color
- Can be used in color-specific goals

### 3. Combat System (Monster.swift, DiceGoal.swift)

#### Dice Goals
Goals the player must achieve to damage monsters:

**Basic Goals:**
- `pair`: Two dice with the same number
- `twoPair`: Two different pairs
- `threeOfAKind`: Three dice with the same number
- `fourOfAKind`: Four dice with the same number
- `fiveOfAKind`: Five dice with the same number
- `sixOfAKind`: All six dice show the same number

**Straight Goals:**
- `smallStraight`: Four consecutive numbers (e.g., 1,2,3,4)
- `largeStraight`: Five consecutive numbers (e.g., 2,3,4,5,6)
- `fullStraight`: All six dice showing 1,2,3,4,5,6

**Advanced Goals:**
- `fullHouse`: Three of one number and two of another
- `colorMatch`: A specific colored die must show a specific value
- `colorPair`: Two specific colored dice must show the same value

#### Damage System
- Player takes damage each roll (varies by monster)
- Player deals 10 damage per goal achieved
- Multiple goals can be met in one roll

### 4. Monster System (Monster.swift)

#### Monster Types by Difficulty

**Easy (1-2 difficulty):**
- Slime 🟢: 20 HP, 2 damage, requires pair
- Rat 🐀: 15 HP, 2 damage, requires pair
- Spider 🕷️: 25 HP, 3 damage, requires two pair
- Bat 🦇: 18 HP, 2 damage, requires three of a kind

**Medium (3-5 difficulty):**
- Goblin 👺: 35 HP, 4 damage, requires three of a kind
- Skeleton 💀: 40 HP, 4 damage, requires full house
- Zombie 🧟: 50 HP, 5 damage, requires four of a kind
- Orc 👹: 45 HP, 5 damage, requires small straight
- Ghost 👻: 38 HP, 4 damage, requires two pair + purple die showing 6

**Hard (6-8 difficulty):**
- Troll 🧌: 70 HP, 6 damage, requires four of a kind
- Vampire 🧛: 65 HP, 7 damage, requires large straight + red die showing 6
- Werewolf 🐺: 75 HP, 6 damage, requires five of a kind
- Demon 😈: 80 HP, 7 damage, requires full house + red/orange dice matching

**Boss (9-10 difficulty):**
- Dragon 🐉: 120 HP, 8 damage, requires full straight + red die showing 6
- Lich ☠️: 100 HP, 9 damage, requires six of a kind + purple die showing 6
- Hydra 🐍: 150 HP, 7 damage, requires full straight + green/blue dice matching

### 5. Encounter System (Encounter.swift)

#### Room Generation
- **Rooms 1-3**: Easy monsters (1-3 monsters)
- **Rooms 4-7**: Medium monsters (1-2 monsters)
- **Rooms 8-12**: Hard monsters (1-2 monsters)
- **Room 13+**: Boss encounters (1 boss monster)
- **Every 5th room**: Guaranteed boss encounter

#### Difficulty Scaling
- Monster HP increases by 15% per room
- Boss fights scale by 20% per room

#### Rewards
- **XP**: Equal to total HP of all defeated monsters
- **Healing**: 10 HP + (5 HP × number of monsters)
- **Level Up**: Full heal + 10 max HP

## Game Flow

1. **Start**: Player begins in Room 1 with 50 HP
2. **Encounter**: Random monsters appear based on room number
3. **Combat Loop**:
   - Roll all 6 dice
   - Check if any monster goals are met
   - If goals met: Deal damage to monster
   - If goals not met: Take damage from all active monsters
   - Repeat until all monsters defeated or player dies
4. **Room Complete**: Heal and gain XP
5. **Next Room**: Advance to next room with new encounter
6. **Game Over**: When player reaches 0 HP

## UI Elements

- **Player Stats**: HP, XP, Level (top left)
- **Monster Info**: Current monster type, HP (top right)
- **Room Number**: Current room (top center)
- **Goals Display**: Shows what dice combinations defeat the current monster
- **Dice Grid**: 6 colored dice in 2 rows of 3
- **Roll Button**: Rolls all dice (or advances to next room)
- **Result Display**: Shows roll results and combat outcomes

## Key Features

✅ Progressive difficulty
✅ Multiple monster types with unique requirements
✅ Color-specific dice goals for advanced monsters
✅ Experience and leveling system
✅ Healing between rooms
✅ Boss encounters every 5 rooms
✅ Multiple goals can be achieved per roll
✅ Strategic depth through dice goal variety
