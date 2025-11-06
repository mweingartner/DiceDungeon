# Image File Reference

## Required Image Files

All images should be PNG format, ideally 256x256 pixels or larger for best quality.
**All images should be added to the Asset Catalog (Assets.xcassets) as individual image sets.**

### Player Image
- **Asset Name:** `player` (add player.png to this image set)

### Monster Images (by difficulty)

#### Easy Monsters (1-2 difficulty)
- **Asset Name:** `slime` - 🟢 Slime (add slime.png)
- **Asset Name:** `rat` - 🐀 Rat (add rat.png)
- **Asset Name:** `spider` - 🕷️ Spider (add spider.png)
- **Asset Name:** `bat` - 🦇 Bat (add bat.png)

#### Medium Monsters (3-5 difficulty)
- **Asset Name:** `goblin` - 👺 Goblin (add goblin.png)
- **Asset Name:** `skeleton` - 💀 Skeleton (add skeleton.png)
- **Asset Name:** `zombie` - 🧟 Zombie (add zombie.png)
- **Asset Name:** `orc` - 👹 Orc (add orc.png)
- **Asset Name:** `ghost` - 👻 Ghost (add ghost.png)

#### Hard Monsters (6-8 difficulty)
- **Asset Name:** `troll` - 🧌 Troll (add troll.png)
- **Asset Name:** `vampire` - 🧛 Vampire (add vampire.png)
- **Asset Name:** `werewolf` - 🐺 Werewolf (add werewolf.png)
- **Asset Name:** `demon` - 😈 Demon (add demon.png)

#### Boss Monsters (9-10 difficulty)
- **Asset Name:** `dragon` - 🐉 Dragon (add dragon.png)
- **Asset Name:** `lich` - ☠️ Lich (add lich.png)
- **Asset Name:** `hydra` - 🐍 Hydra (add hydra.png)

## Total Files Needed
- 1 player image
- 16 monster images
- **17 images total**

## How to Add to Asset Catalog
1. Open your project in Xcode
2. Locate **Assets.xcassets** in the Project Navigator
3. For each image:
   - Click the **+** button at the bottom of the Asset Catalog
   - Choose **Image Set**
   - Name it exactly as shown above (e.g., "player", "slime", "dragon")
   - Drag your PNG file into the **1x**, **2x**, or **Any** slot

## Notes
- Asset names must match exactly (case-sensitive)
- Do NOT include the .png extension in the asset name
- Images will be compiled into the app bundle efficiently
- Recommended size: 256x256 pixels minimum
- Images will be scaled to fit a 256x256 display area
- Missing images will show as blank/error in SpriteKit
