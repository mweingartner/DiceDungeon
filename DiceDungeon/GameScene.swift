//
//  GameScene.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/3/25.
//

import SpriteKit
import GameplayKit

class DiceNode: SKNode {
    private let diceSize: CGFloat = 80
    private let pipRadius: CGFloat = 6
    private var background: SKShapeNode!
    private var value: Int = 1
    var color: DiceColor
    
    init(color: DiceColor) {
        self.color = color
        super.init()
        setupDice()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.color = .red
        super.init(coder: aDecoder)
        setupDice()
    }
    
    private func setupDice() {
        // Create dice background with color
        background = SKShapeNode(rectOf: CGSize(width: diceSize, height: diceSize), cornerRadius: 10)
        background.fillColor = color.skColor
        background.strokeColor = .white
        background.lineWidth = 3
        addChild(background)
        
        // Start with value 1
        updatePips(value: 1)
    }
    
    func setValue(_ newValue: Int) {
        value = newValue
        updatePips(value: newValue)
    }
    
    func flash() {
        let flash = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        background.run(flash)
    }
    
    private func updatePips(value: Int) {
        // Remove old pips
        children.filter { $0.name == "pip" }.forEach { $0.removeFromParent() }
        
        let offset: CGFloat = diceSize / 4
        
        switch value {
        case 1:
            createPip(at: CGPoint(x: 0, y: 0))
        case 2:
            createPip(at: CGPoint(x: -offset, y: offset))
            createPip(at: CGPoint(x: offset, y: -offset))
        case 3:
            createPip(at: CGPoint(x: -offset, y: offset))
            createPip(at: CGPoint(x: 0, y: 0))
            createPip(at: CGPoint(x: offset, y: -offset))
        case 4:
            createPip(at: CGPoint(x: -offset, y: offset))
            createPip(at: CGPoint(x: offset, y: offset))
            createPip(at: CGPoint(x: -offset, y: -offset))
            createPip(at: CGPoint(x: offset, y: -offset))
        case 5:
            createPip(at: CGPoint(x: -offset, y: offset))
            createPip(at: CGPoint(x: offset, y: offset))
            createPip(at: CGPoint(x: 0, y: 0))
            createPip(at: CGPoint(x: -offset, y: -offset))
            createPip(at: CGPoint(x: offset, y: -offset))
        case 6:
            createPip(at: CGPoint(x: -offset, y: offset))
            createPip(at: CGPoint(x: offset, y: offset))
            createPip(at: CGPoint(x: -offset, y: 0))
            createPip(at: CGPoint(x: offset, y: 0))
            createPip(at: CGPoint(x: -offset, y: -offset))
            createPip(at: CGPoint(x: offset, y: -offset))
        default:
            break
        }
    }
    
    private func createPip(at position: CGPoint) {
        let pip = SKShapeNode(circleOfRadius: pipRadius)
        pip.position = position
        pip.fillColor = .white
        pip.strokeColor = .white
        pip.name = "pip"
        addChild(pip)
    }
    
    func getValue() -> Int {
        return value
    }
    
    func rollAnimation(completion: @escaping (Int) -> Void) {
        // Random final value
        let finalValue = Int.random(in: 1...6)
        
        // Create rolling animation - rapidly change dice faces
        let rollDuration = 1.5
        let steps = 15
        let stepDuration = rollDuration / Double(steps)
        
        var actions: [SKAction] = []
        
        for _ in 0..<steps {
            let randomValue = Int.random(in: 1...6)
            actions.append(SKAction.run {
                self.updatePips(value: randomValue)
            })
            actions.append(SKAction.wait(forDuration: stepDuration))
        }
        
        // Add final value
        actions.append(SKAction.run {
            self.setValue(finalValue)
            completion(finalValue)
        })
        
        // Add rotation and scaling for visual effect
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 4, duration: rollDuration)
        let scaleUp = SKAction.scale(to: 1.2, duration: rollDuration / 2)
        let scaleDown = SKAction.scale(to: 1.0, duration: rollDuration / 2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        
        let group = SKAction.group([SKAction.sequence(actions), rotate, scaleSequence])
        run(group)
    }
}

class GameScene: SKScene {
    
    // Game state
    private var player: Player!
    private var currentEncounter: Encounter?
    private var roomNumber: Int = 1
    private var rollCount: Int = 0
    private var hasRolled: Bool = false
    private var rewardCompletionHandler: (() -> Void)?
    private var restCompletionHandler: (() -> Void)?
    private var gameEnded: Bool = false // New flag to prevent multiple game over triggers
    
    // Skill State
    enum SkillMode {
        case none
        case nudge
        case flip
        case focus
    }
    private var currentSkillMode: SkillMode = .none
    
    // UI elements
    private var dice: [DiceNode] = []
    private var diceSlots: [SKShapeNode] = []
    private var slottedDice: [Int: DiceNode] = [:] // slot index -> dice node
    
    // Core Buttons
    private var rollButton: SKShapeNode!
    private var rollButtonLabel: SKLabelNode!
    private var checkButton: SKShapeNode!
    private var checkButtonLabel: SKLabelNode!
    private var runButton: SKShapeNode!
    private var runButtonLabel: SKLabelNode!
    private var newGameButton: SKShapeNode!
    private var newGameButtonLabel: SKLabelNode!
    
    // Skill Buttons
    private var skillNudgeButton: SKShapeNode!
    private var skillFlipButton: SKShapeNode!
    private var skillFocusButton: SKShapeNode!
    
    // Labels
    private var resultLabel: SKLabelNode!
    private var playerHPLabel: SKLabelNode!
    private var playerManaLabel: SKLabelNode!
    private var playerXPLabel: SKLabelNode!
    private var monsterInfoLabel: SKLabelNode!
    private var monsterHPLabel: SKLabelNode!
    private var goalsLabel: SKLabelNode!
    private var roomNumberLabel: SKLabelNode!
    private var rollCountLabel: SKLabelNode!
    private var titleLabel: SKLabelNode!
    private var leaderboardTitleLabel: SKLabelNode!
    private var leaderboardLabels: [SKLabelNode] = []
    private var playerImageNode: SKSpriteNode!
    private var monsterImageNode: SKSpriteNode!
    private var isRolling = false
    private var highScores: [HighScore] = []
    
    // Colors for dice (rainbow order)
    private let diceColors: [DiceColor] = [.red, .orange, .yellow, .green, .blue, .purple]
    
    // Original dice positions (for moving back)
    private var originalDicePositions: [CGPoint] = []
    
    // Layout constants (relative to scene size)
    private struct Layout {
        static let minWidth: CGFloat = 800
        static let minHeight: CGFloat = 600
        static let padding: CGFloat = 20
        static let titleYOffset: CGFloat = 60
        static let roomYOffset: CGFloat = 120  // Room number label
        static let rollCountYOffset: CGFloat = 155  // Roll count info
        static let playerStatsYOffset: CGFloat = 60
        static let playerManaYOffset: CGFloat = 90
        static let playerXPYOffset: CGFloat = 120
        static let leaderboardYOffset: CGFloat = 237
        static let leaderboardLineHeight: CGFloat = 20
        static let characterImageSize: CGFloat = 256
        static let characterImageFromBottom: CGFloat = 256
        static let monsterStatsYOffset: CGFloat = 60
        static let monsterHPYOffset: CGFloat = 90
        static let goalsYOffset: CGFloat = 230
        static let skillButtonSize: CGFloat = 50
        
        // Adjusted offsets for bottom UI elements to prevent overlap
        static let buttonYOffset: CGFloat = 60          // Moved down (was 80)
        static let skillButtonYOffset: CGFloat = 120    // New position above main buttons
        static let resultYOffset: CGFloat = 170         // Moved up (was 160)
        
        static let buttonWidth: CGFloat = 180
        static let buttonHeight: CGFloat = 60
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        
        // Initialize game
        player = Player()
        currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
        rollCount = 0
        hasRolled = false
        gameEnded = false
        
        setupUI()
        setupDice()
        setupSlots()
        updateUI()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        // Remove all existing UI and recreate it when the window is resized
        removeAllChildren()
        dice.removeAll()
        diceSlots.removeAll()
        slottedDice.removeAll()
        originalDicePositions.removeAll()
        
        // Reinitialize if needed
        if player == nil {
            player = Player()
            currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
            rollCount = 0
            hasRolled = false
        }
        
        setupUI()
        setupDice()
        setupSlots()
        updateUI()
    }
    
    private func setupUI() {
        let sceneWidth = max(size.width, Layout.minWidth)
        _ = max(size.height, Layout.minHeight) // For potential future use
        
        // Calculate scaled font sizes based on scene size
        let titleFontSize = min(48, sceneWidth / 20)
        let largeFontSize = min(28, sceneWidth / 30)
        let mediumFontSize = min(24, sceneWidth / 35)
        let normalFontSize = min(20, sceneWidth / 40)
        let smallFontSize = min(18, sceneWidth / 45)
        
        // Title
        titleLabel = SKLabelNode(fontNamed: "Arial Bold")
        titleLabel.text = "⚔️ Dice Dungeon ⚔️"
        titleLabel.fontSize = titleFontSize
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - Layout.titleYOffset)
        addChild(titleLabel)
        
        // Room number
        roomNumberLabel = SKLabelNode(fontNamed: "Arial Bold")
        roomNumberLabel.fontSize = mediumFontSize
        roomNumberLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        roomNumberLabel.position = CGPoint(x: size.width / 2, y: size.height - Layout.roomYOffset)
        addChild(roomNumberLabel)
        
        // Roll count (below room number)
        rollCountLabel = SKLabelNode(fontNamed: "Arial")
        rollCountLabel.fontSize = normalFontSize
        rollCountLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        rollCountLabel.position = CGPoint(x: size.width / 2, y: size.height - Layout.rollCountYOffset)
        addChild(rollCountLabel)
        
        // Player HP (left side)
        playerHPLabel = SKLabelNode(fontNamed: "Arial Bold")
        playerHPLabel.fontSize = largeFontSize
        playerHPLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        playerHPLabel.position = CGPoint(x: Layout.padding + 100, y: size.height - Layout.playerStatsYOffset)
        playerHPLabel.horizontalAlignmentMode = .left
        addChild(playerHPLabel)
        
        // Player Mana (left side)
        playerManaLabel = SKLabelNode(fontNamed: "Arial Bold")
        playerManaLabel.fontSize = mediumFontSize
        playerManaLabel.fontColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        playerManaLabel.position = CGPoint(x: Layout.padding + 100, y: size.height - Layout.playerManaYOffset)
        playerManaLabel.horizontalAlignmentMode = .left
        addChild(playerManaLabel)
        
        // Player XP (left side)
        playerXPLabel = SKLabelNode(fontNamed: "Arial")
        playerXPLabel.fontSize = normalFontSize
        playerXPLabel.fontColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        playerXPLabel.position = CGPoint(x: Layout.padding + 100, y: size.height - Layout.playerXPYOffset)
        playerXPLabel.horizontalAlignmentMode = .left
        addChild(playerXPLabel)
        
        // Leaderboard (left side, below player XP)
        leaderboardTitleLabel = SKLabelNode(fontNamed: "Arial Bold")
        leaderboardTitleLabel.text = "🏆 TOP SCORES 🏆"
        leaderboardTitleLabel.fontSize = normalFontSize
        leaderboardTitleLabel.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        leaderboardTitleLabel.position = CGPoint(x: Layout.padding + 100, y: size.height - Layout.leaderboardYOffset)
        leaderboardTitleLabel.horizontalAlignmentMode = .left
        addChild(leaderboardTitleLabel)
        
        // Create 10 leaderboard entry labels
        leaderboardLabels.removeAll()
        for i in 0..<10 {
            let label = SKLabelNode(fontNamed: "Courier")
            label.fontSize = smallFontSize - 2
            label.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            label.position = CGPoint(x: Layout.padding + 100, 
                                    y: size.height - Layout.leaderboardYOffset - 25 - CGFloat(i) * Layout.leaderboardLineHeight)
            label.horizontalAlignmentMode = .left
            label.text = String(format: "%2d. --- ----", i + 1)
            addChild(label)
            leaderboardLabels.append(label)
        }
        
        highScores = HighScoreManager.shared.loadScores()
        updateLeaderboard()
        
        // Player image
        let playerImageTexture = SKTexture(imageNamed: "player")
        playerImageNode = SKSpriteNode(texture: playerImageTexture)
        playerImageNode.size = CGSize(width: Layout.characterImageSize, height: Layout.characterImageSize)
        playerImageNode.position = CGPoint(x: Layout.padding + Layout.characterImageSize / 2, 
                                          y: Layout.characterImageFromBottom)
        addChild(playerImageNode)
        
        // Monster image placeholder
        if let encounter = currentEncounter, let monster = encounter.currentMonster {
            let monsterImageName = monster.type.rawValue
            let monsterImageTexture = SKTexture(imageNamed: monsterImageName)
            monsterImageNode = SKSpriteNode(texture: monsterImageTexture)
            monsterImageNode.size = CGSize(width: Layout.characterImageSize, height: Layout.characterImageSize)
            monsterImageNode.position = CGPoint(x: size.width - Layout.padding - Layout.characterImageSize / 2, 
                                               y: Layout.characterImageFromBottom)
            addChild(monsterImageNode)
        }
        
        // Monster info (right side)
        monsterInfoLabel = SKLabelNode(fontNamed: "Arial Bold")
        monsterInfoLabel.fontSize = largeFontSize
        monsterInfoLabel.fontColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        monsterInfoLabel.position = CGPoint(x: size.width - Layout.padding - 100, y: size.height - Layout.monsterStatsYOffset)
        monsterInfoLabel.horizontalAlignmentMode = .right
        addChild(monsterInfoLabel)
        
        // Monster HP (right side)
        monsterHPLabel = SKLabelNode(fontNamed: "Arial")
        monsterHPLabel.fontSize = normalFontSize
        monsterHPLabel.fontColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        monsterHPLabel.position = CGPoint(x: size.width - Layout.padding - 100, y: size.height - Layout.monsterHPYOffset)
        monsterHPLabel.horizontalAlignmentMode = .right
        addChild(monsterHPLabel)
        
        // Goals label
        goalsLabel = SKLabelNode(fontNamed: "Arial")
        goalsLabel.fontSize = smallFontSize
        goalsLabel.fontColor = SKColor(red: 1.0, green: 1.0, blue: 0.6, alpha: 1.0)
        goalsLabel.position = CGPoint(x: size.width - Layout.padding - 100, y: size.height - Layout.goalsYOffset)
        goalsLabel.numberOfLines = 0
        goalsLabel.preferredMaxLayoutWidth = 400
        goalsLabel.horizontalAlignmentMode = .right
        addChild(goalsLabel)
        
        // Main Buttons
        let buttonSpacingFor3 = Layout.buttonWidth + 40
        let totalWidth = buttonSpacingFor3 * 2
        let startX = (size.width - totalWidth) / 2
        
        // Roll button
        rollButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        rollButton.position = CGPoint(x: startX, y: Layout.buttonYOffset)
        rollButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        rollButton.strokeColor = .white
        rollButton.lineWidth = 3
        rollButton.name = "rollButton"
        addChild(rollButton)
        
        rollButtonLabel = SKLabelNode(fontNamed: "Arial Bold")
        rollButtonLabel.text = "ROLL DICE"
        rollButtonLabel.fontSize = min(22, normalFontSize + 2)
        rollButtonLabel.fontColor = .white
        rollButtonLabel.verticalAlignmentMode = .center
        rollButton.addChild(rollButtonLabel)
        
        // Check button
        checkButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        checkButton.position = CGPoint(x: startX + buttonSpacingFor3, y: Layout.buttonYOffset)
        checkButton.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        checkButton.strokeColor = .white
        checkButton.lineWidth = 3
        checkButton.name = "checkButton"
        checkButton.alpha = 0.5
        addChild(checkButton)
        
        checkButtonLabel = SKLabelNode(fontNamed: "Arial Bold")
        checkButtonLabel.text = "CHECK"
        checkButtonLabel.fontSize = min(22, normalFontSize + 2)
        checkButtonLabel.fontColor = .white
        checkButtonLabel.verticalAlignmentMode = .center
        checkButton.addChild(checkButtonLabel)
        
        // Run button
        runButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        runButton.position = CGPoint(x: startX + buttonSpacingFor3 * 2, y: Layout.buttonYOffset)
        runButton.fillColor = SKColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)
        runButton.strokeColor = .white
        runButton.lineWidth = 3
        runButton.name = "runButton"
        addChild(runButton)
        
        runButtonLabel = SKLabelNode(fontNamed: "Arial Bold")
        runButtonLabel.text = "🏃 RUN"
        runButtonLabel.fontSize = min(22, normalFontSize + 2)
        runButtonLabel.fontColor = .white
        runButtonLabel.verticalAlignmentMode = .center
        runButton.addChild(runButtonLabel)
        
        // --- SKILL BUTTONS ---
        let skillY = Layout.skillButtonYOffset
        let skillGap: CGFloat = 140
        
        // Nudge Button
        skillNudgeButton = createSkillButton(text: "Nudge", icon: "☝️", color: .cyan, position: CGPoint(x: size.width/2 - skillGap, y: skillY))
        skillNudgeButton.name = "skillNudge"
        addChild(skillNudgeButton)
        
        // Flip Button
        skillFlipButton = createSkillButton(text: "Flip", icon: "🔄", color: .magenta, position: CGPoint(x: size.width/2, y: skillY))
        skillFlipButton.name = "skillFlip"
        addChild(skillFlipButton)
        
        // Focus Button
        skillFocusButton = createSkillButton(text: "Focus", icon: "🎯", color: .yellow, position: CGPoint(x: size.width/2 + skillGap, y: skillY))
        skillFocusButton.name = "skillFocus"
        addChild(skillFocusButton)
        
        // New Game button
        newGameButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth * 0.75, height: Layout.buttonHeight * 0.65), cornerRadius: 8)
        newGameButton.position = CGPoint(x: Layout.padding + (Layout.buttonWidth * 0.375), y: size.height - Layout.playerXPYOffset - 35)
        newGameButton.fillColor = SKColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        newGameButton.strokeColor = .white
        newGameButton.lineWidth = 2
        newGameButton.name = "newGameButton"
        addChild(newGameButton)
        
        newGameButtonLabel = SKLabelNode(fontNamed: "Arial Bold")
        newGameButtonLabel.text = "🔄 NEW GAME"
        newGameButtonLabel.fontSize = min(17, normalFontSize - 3)
        newGameButtonLabel.fontColor = .white
        newGameButtonLabel.verticalAlignmentMode = .center
        newGameButton.addChild(newGameButtonLabel)
        
        // Result label
        resultLabel = SKLabelNode(fontNamed: "Arial")
        resultLabel.fontSize = normalFontSize
        resultLabel.fontColor = .white
        resultLabel.position = CGPoint(x: size.width / 2, y: Layout.resultYOffset)
        resultLabel.numberOfLines = 0
        resultLabel.preferredMaxLayoutWidth = size.width - Layout.padding * 10
        addChild(resultLabel)
    }
    
    private func createSkillButton(text: String, icon: String, color: SKColor, position: CGPoint) -> SKShapeNode {
        let btn = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 8)
        btn.position = position
        btn.fillColor = color.withAlphaComponent(0.3)
        btn.strokeColor = color
        btn.lineWidth = 2
        
        let label = SKLabelNode(fontNamed: "Arial Bold")
        label.text = "\(icon) \(text) (1 MP)"
        label.fontSize = 14
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = "label"
        btn.addChild(label)
        
        return btn
    }
    
    private func setupDice() {
        // Scale dice based on scene size
        let sceneWidth = max(size.width, Layout.minWidth)
        
        let diceSpacing = min(110, sceneWidth / 8)
        let dicePerRow: CGFloat = 3
        
        let totalWidth = (dicePerRow - 1) * diceSpacing
        let startX = (size.width - totalWidth) / 2
        
        // Shifted dice UP to make room for UI at bottom
        let topRowY = size.height / 2 + 40 + diceSpacing * 0.55
        let bottomRowY = size.height / 2 + 40 - diceSpacing * 0.55
        
        // Top row
        for i in 0..<3 {
            let dice = DiceNode(color: diceColors[i])
            let position = CGPoint(x: startX + CGFloat(i) * diceSpacing, y: topRowY)
            dice.position = position
            dice.setValue(1)
            dice.name = "dice_\(i)"
            self.dice.append(dice)
            self.originalDicePositions.append(position)
            addChild(dice)
        }
        
        // Bottom row
        for i in 0..<3 {
            let dice = DiceNode(color: diceColors[i + 3])
            let position = CGPoint(x: startX + CGFloat(i) * diceSpacing, y: bottomRowY)
            dice.position = position
            dice.setValue(1)
            dice.name = "dice_\(i + 3)"
            self.dice.append(dice)
            self.originalDicePositions.append(position)
            addChild(dice)
        }
    }
    
    private func setupSlots() {
        let sceneWidth = max(size.width, Layout.minWidth)
        let slotSize: CGFloat = min(90, sceneWidth / 10)
        let slotSpacing = min(100, sceneWidth / 9)
        let slotsPerRow: CGFloat = 6
        
        let totalWidth = (slotsPerRow - 1) * slotSpacing
        let startX = (size.width - totalWidth) / 2
        
        // Position slots well below the dice area to avoid overlap
        // Dice are at size.height / 2 + 40 ± ~55, so we drop slots much lower
        // Place them about halfway between dice center and result label
        let slotY = size.height / 2 - 120 // Dropped down significantly
        
        for i in 0..<6 {
            let slot = SKShapeNode(rectOf: CGSize(width: slotSize, height: slotSize), cornerRadius: 10)
            slot.position = CGPoint(x: startX + CGFloat(i) * slotSpacing, y: slotY)
            slot.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.5)
            slot.strokeColor = SKColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
            slot.lineWidth = 2
            slot.name = "slot_\(i)"
            diceSlots.append(slot)
            addChild(slot)
        }
    }
    
    private func updateUI() {
        // Update player info
        playerHPLabel.text = "❤️ HP: \(player.currentHP)/\(player.maxHP)"
        playerManaLabel.text = "💧 Mana: \(player.currentMana)/\(player.maxMana)"
        playerXPLabel.text = "⭐️ XP: \(player.experience) | Level: \(player.level)"
        
        updateMonsterImage()
        
        roomNumberLabel.text = "Room \(roomNumber)"
        rollCountLabel.text = "Rolls: \(rollCount) | Damage taken: \((max(0, rollCount - 1)) * 10) HP"
        if rollCount <= 1 {
            rollCountLabel.fontColor = SKColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        } else {
            rollCountLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        }
        
        if let encounter = currentEncounter, let monster = encounter.currentMonster {
            monsterInfoLabel.text = "\(monster.type.emoji) \(monster.type.displayName)"
            let completed = monster.goalsCompleted.count
            let total = monster.goals.count
            monsterHPLabel.text = "Goals: \(completed)/\(total)"
            
            let remainingGoalsText = monster.remainingGoals.map { "• \($0.description)" }.joined(separator: "\n")
            if remainingGoalsText.isEmpty {
                goalsLabel.text = "All goals complete! Monster defeated!"
            } else {
                goalsLabel.text = "Goals to complete:\n\(remainingGoalsText)"
            }
        } else {
            monsterInfoLabel.text = ""
            monsterHPLabel.text = ""
            goalsLabel.text = ""
        }
        
        // Update Buttons
        if hasRolled && !slottedDice.isEmpty {
            checkButton.alpha = 1.0
        } else {
            checkButton.alpha = 0.5
        }
        
        if !player.isAlive || currentEncounter?.isComplete == true {
            runButton.alpha = 0.5
            skillNudgeButton.alpha = 0.3
            skillFlipButton.alpha = 0.3
            skillFocusButton.alpha = 0.3
        } else {
            runButton.alpha = 1.0
            // Update skill buttons based on Mana
            updateSkillButtons()
        }
        
        // Update result label only if not in skill mode
        if currentSkillMode != .none {
            return
        }
        
        if !player.isAlive {
            if !gameEnded { // Only trigger once
                gameEnded = true
                resultLabel.text = "💀 You have been defeated! 💀\nFinal Score: Room \(roomNumber), \(player.experience) XP"
                
                // Disable buttons immediately
                rollButton.alpha = 0.5
                checkButton.alpha = 0.5
                runButton.alpha = 0.5
                skillNudgeButton.alpha = 0.3
                skillFlipButton.alpha = 0.3
                skillFocusButton.alpha = 0.3
                
                let wait = SKAction.wait(forDuration: 1.0)
                let showDialog = SKAction.run { [weak self] in
                    self?.handleGameEnd()
                }
                run(SKAction.sequence([wait, showDialog]))
            }
        } else if currentEncounter?.isComplete == true {
            resultLabel.text = "🎉 Room cleared! Health & Mana restored!"
        } else if !hasRolled {
            resultLabel.text = "Click 'ROLL DICE' or press SPACE to roll all dice!"
        } else if slottedDice.isEmpty {
            resultLabel.text = "Click dice to place them in slots, then press 'CHECK' or 'ROLL AGAIN'"
        } else {
            resultLabel.text = "Place more dice in slots or press 'CHECK'. Reroll unslotted dice anytime!"
        }
    }
    
    private func updateSkillButtons() {
        let canAfford = player.currentMana >= 1 && hasRolled && player.isAlive && currentEncounter?.isComplete == false
        
        // Helper to style button based on state
        func styleButton(_ btn: SKShapeNode, active: Bool, selected: Bool) {
            if selected {
                btn.alpha = 1.0
                btn.fillColor = .white
                if let label = btn.childNode(withName: "label") as? SKLabelNode {
                    label.fontColor = .black
                }
            } else if active {
                btn.alpha = 1.0
                btn.fillColor = btn.strokeColor.withAlphaComponent(0.3)
                if let label = btn.childNode(withName: "label") as? SKLabelNode {
                    label.fontColor = .white
                }
            } else {
                btn.alpha = 0.3
                btn.fillColor = btn.strokeColor.withAlphaComponent(0.1)
                if let label = btn.childNode(withName: "label") as? SKLabelNode {
                    label.fontColor = .white
                }
            }
        }
        
        styleButton(skillNudgeButton, active: canAfford, selected: currentSkillMode == .nudge)
        styleButton(skillFlipButton, active: canAfford, selected: currentSkillMode == .flip)
        styleButton(skillFocusButton, active: canAfford, selected: currentSkillMode == .focus)
    }
    
    private func updateMonsterImage() {
        guard let encounter = currentEncounter, let monster = encounter.currentMonster else {
            monsterImageNode?.isHidden = true
            return
        }
        
        let monsterImageName = monster.type.rawValue
        let monsterImageTexture = SKTexture(imageNamed: monsterImageName)
        
        if monsterImageNode == nil {
            monsterImageNode = SKSpriteNode(texture: monsterImageTexture)
            monsterImageNode.size = CGSize(width: Layout.characterImageSize, height: Layout.characterImageSize)
            monsterImageNode.position = CGPoint(x: size.width - Layout.padding - Layout.characterImageSize / 2, 
                                               y: Layout.characterImageFromBottom)
            addChild(monsterImageNode)
        } else {
            monsterImageNode.texture = monsterImageTexture
            monsterImageNode.isHidden = false
        }
    }
    
    private func rollAllDice() {
        // Cancel any active skill
        if currentSkillMode != .none {
            currentSkillMode = .none
            updateUI()
        }
        
        guard !isRolling else { return }
        guard player.isAlive else { return }
        guard currentEncounter?.isComplete == false else { return }
        
        if hasRolled {
            rollCount += 1
            let damage = 10
            player.takeDamage(damage)
            
            if !player.isAlive {
                resultLabel.text = "💀 You died from too many rolls!"
                updateUI()
                return
            }
        } else {
            rollCount = 1
        }
        
        isRolling = true
        hasRolled = true
        rollButtonLabel.text = "ROLLING..."
        rollButton.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        let shouldClearSlots = slottedDice.isEmpty
        if shouldClearSlots {
            clearAllSlots()
        }
        
        var diceToRoll: [Int] = []
        for (index, dice) in self.dice.enumerated() {
            let isSlotted = slottedDice.values.contains(dice)
            if !isSlotted {
                diceToRoll.append(index)
            }
        }
        
        var completedDice = 0
        let totalDiceToRoll = diceToRoll.count
        
        for diceIndex in diceToRoll {
            let dice = self.dice[diceIndex]
            let delay = Double(diceToRoll.firstIndex(of: diceIndex) ?? 0) * 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                dice.rollAnimation { value in
                    completedDice += 1
                    if completedDice == totalDiceToRoll {
                        self.isRolling = false
                        self.rollButtonLabel.text = "ROLL AGAIN"
                        self.rollButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
                        self.updateUI()
                    }
                }
            }
        }
        
        if totalDiceToRoll == 0 {
            isRolling = false
            rollButtonLabel.text = "ROLL AGAIN"
            rollButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
            updateUI()
        }
    }
    
    private func clearAllSlots() {
        for (_, dice) in slottedDice {
            if let diceIndex = self.dice.firstIndex(of: dice) {
                let moveBack = SKAction.move(to: originalDicePositions[diceIndex], duration: 0.3)
                dice.run(moveBack)
            }
        }
        slottedDice.removeAll()
    }
    
    private func resetDiceToOne() {
        for dice in self.dice {
            dice.setValue(1)
        }
    }
    
    private func checkGoals() {
        // Cancel any active skill
        if currentSkillMode != .none {
            currentSkillMode = .none
            updateUI()
        }
        
        guard hasRolled else { return }
        guard !slottedDice.isEmpty else { return }
        guard let encounter = currentEncounter,
              let monster = encounter.currentMonster else { return }
        
        var results: [DiceResult] = []
        for i in 0..<6 {
            if let dice = slottedDice[i] {
                let result = DiceResult(color: dice.color, value: dice.getValue())
                results.append(result)
            }
        }
        
        var goalsMet: [Int] = []
        for (index, goal) in monster.goals.enumerated() {
            if monster.goalsCompleted.contains(index) { continue }
            if goal.isMet(by: results) {
                goalsMet.append(index)
            }
        }
        
        var message = ""
        let valuesText = results.map { "\($0.color.displayName): \($0.value)" }.joined(separator: ", ")
        message += "Slotted: \(valuesText)\n\n"
        
        if !goalsMet.isEmpty {
            goalsMet.forEach { monster.markGoalCompleted(at: $0) }
            message += "✅ Goals completed!\n"
            goalsMet.forEach { index in
                message += "• \(monster.goals[index].description)\n"
            }
            
            if monster.isDefeated {
                message += "\n💥 ALL GOALS COMPLETE! Monster defeated!"
                if encounter.isComplete {
                    handleEncounterComplete()
                    return
                } else {
                    message += "\n\n🎯 \(monster.type.displayName) defeated!"
                    handleMonsterDefeated(message: message)
                    return
                }
            } else {
                let remaining = monster.remainingGoals.count
                message += "\n\n🎯 Progress! \(remaining) goal(s) remaining!"
                hasRolled = false
                clearAllSlots()
                rollButtonLabel.text = "ROLL DICE"
            }
        } else {
            message += "❌ No new goals achieved! Try different dice combinations."
        }
        
        resultLabel.text = message
        
        // Manual updates
        playerHPLabel.text = "❤️ HP: \(player.currentHP)/\(player.maxHP)"
        playerManaLabel.text = "💧 Mana: \(player.currentMana)/\(player.maxMana)"
        
        if let encounter = currentEncounter, let monster = encounter.currentMonster {
            let completed = monster.goalsCompleted.count
            let total = monster.goals.count
            monsterHPLabel.text = "Goals: \(completed)/\(total)"
        }
        
        if hasRolled && !slottedDice.isEmpty {
            checkButton.alpha = 1.0
        } else {
            checkButton.alpha = 0.5
        }
    }
    
    private func handleEncounterComplete() {
        guard let encounter = currentEncounter else { return }
        
        rollCount = 0
        hasRolled = false
        currentSkillMode = .none
        
        // Heal Player
        player.currentHP = player.maxHP
        player.restoreMana()
        
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        
        clearAllSlots()
        
        playMonsterDeathAnimation {
            self.showRestAndReward(encounter: encounter) {
                self.prepareNextEncounter()
            }
        }
    }
    
    private func handleMonsterDefeated(message: String) {
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        
        clearAllSlots()
        hasRolled = false
        currentSkillMode = .none
        
        showMonsterDefeatedTransition(message: message) {
            self.restBetweenMonsters()
        }
    }
    
    private func showMonsterDefeatedTransition(message: String, completion: @escaping () -> Void) {
        let fontSize = min(48, size.width / 20)
        let deathLabel = SKLabelNode(fontNamed: "Arial Bold")
        deathLabel.text = "💀 DEFEATED! 💀"
        deathLabel.fontSize = fontSize
        deathLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        deathLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        deathLabel.alpha = 0
        deathLabel.setScale(0.5)
        addChild(deathLabel)
        
        let flashIn = SKAction.fadeAlpha(to: 0.3, duration: 0.15)
        let flashOut = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
        let flash = SKAction.sequence([flashIn, flashOut])
        let flashRepeat = SKAction.repeat(flash, count: 2)
        monsterInfoLabel.run(flashRepeat)
        monsterHPLabel.run(flashRepeat)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let appear = SKAction.group([fadeIn, scaleUp])
        
        let wait = SKAction.wait(forDuration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([appear, wait, fadeOut, remove])
        deathLabel.run(sequence) {
            completion()
        }
    }
    
    private func restBetweenMonsters() {
        guard let encounter = currentEncounter, let nextMonster = encounter.currentMonster else {
            handleEncounterComplete()
            return
        }
        
        let panelWidth = min(450, size.width * 0.6)
        let panelHeight = min(200, size.height * 0.33)
        
        let restPanel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 15)
        restPanel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        restPanel.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.3, alpha: 0.95)
        restPanel.strokeColor = SKColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        restPanel.lineWidth = 3
        restPanel.alpha = 0
        restPanel.setScale(0.8)
        restPanel.name = "restPanel"
        addChild(restPanel)
        
        let restLabel = SKLabelNode(fontNamed: "Arial Bold")
        restLabel.text = "⚔️ One Down! ⚔️"
        restLabel.fontSize = min(32, panelWidth / 14)
        restLabel.fontColor = SKColor(red: 1.0, green: 1.0, blue: 0.6, alpha: 1.0)
        restLabel.position = CGPoint(x: 0, y: panelHeight * 0.25)
        restLabel.verticalAlignmentMode = .center
        restPanel.addChild(restLabel)
        
        let nextLabel = SKLabelNode(fontNamed: "Arial")
        nextLabel.text = "Next: \(nextMonster.type.emoji) \(nextMonster.type.displayName)"
        nextLabel.fontSize = min(20, panelWidth / 22)
        nextLabel.fontColor = SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
        nextLabel.position = CGPoint(x: 0, y: -panelHeight * 0.175)
        nextLabel.verticalAlignmentMode = .center
        restPanel.addChild(nextLabel)
        
        let continueLabel = SKLabelNode(fontNamed: "Arial")
        continueLabel.text = "Click to continue..."
        continueLabel.fontSize = min(16, panelWidth / 28)
        continueLabel.position = CGPoint(x: 0, y: -panelHeight * 0.35)
        continueLabel.verticalAlignmentMode = .center
        restPanel.addChild(continueLabel)
        
        let appear = SKAction.group([SKAction.fadeIn(withDuration: 0.3), SKAction.scale(to: 1.0, duration: 0.3)])
        restPanel.run(appear)
        
        updateUI()
        
        self.restCompletionHandler = { self.dismissRestPanel() }
    }
    
    private func dismissRestPanel() {
        guard let panel = childNode(withName: "restPanel") else { return }
        
        let disappear = SKAction.group([SKAction.fadeOut(withDuration: 0.3), SKAction.scale(to: 0.8, duration: 0.3)])
        let remove = SKAction.removeFromParent()
        
        panel.run(SKAction.sequence([disappear, remove])) {
            self.continueToNextMonster()
        }
    }
    
    private func continueToNextMonster() {
        hasRolled = false
        rollCount = 0
        clearAllSlots()
        currentSkillMode = .none
        
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        resultLabel.text = "Ready to face the next monster!"
        updateUI()
        
        restCompletionHandler = nil
    }
    
    private func playMonsterDeathAnimation(completion: @escaping () -> Void) {
        let fontSize = min(64, size.width / 15)
        
        let deathLabel = SKLabelNode(fontNamed: "Arial Bold")
        deathLabel.text = "💀 DEFEATED! 💀"
        deathLabel.fontSize = fontSize
        deathLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        deathLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        deathLabel.alpha = 0
        deathLabel.setScale(0.5)
        addChild(deathLabel)
        
        let flashIn = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
        let flashOut = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let flash = SKAction.sequence([flashIn, flashOut])
        let flashRepeat = SKAction.repeat(flash, count: 3)
        monsterInfoLabel.run(flashRepeat)
        monsterHPLabel.run(flashRepeat)
        
        let appear = SKAction.group([SKAction.fadeIn(withDuration: 0.3), SKAction.scale(to: 1.5, duration: 0.3)])
        let wait = SKAction.wait(forDuration: 1.0)
        let disappear = SKAction.group([SKAction.scale(to: 1.0, duration: 0.2), SKAction.fadeOut(withDuration: 0.3)])
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([appear, wait, disappear, remove])
        deathLabel.run(sequence) { completion() }
    }
    
    private func showRestAndReward(encounter: Encounter, completion: @escaping () -> Void) {
        let xpGained = encounter.totalXPValue
        let oldLevel = player.level
        
        player.gainExperience(xpGained)
        let leveledUp = player.level > oldLevel
        player.currentHP = player.maxHP
        player.restoreMana() // Refill Mana too
        
        let panelWidth = min(500, size.width * 0.7)
        let panelHeight = min(350, size.height * 0.5)
        
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 20)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = SKColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 0.95)
        panel.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.3, alpha: 1.0)
        panel.lineWidth = 4
        panel.alpha = 0
        panel.setScale(0.5)
        panel.name = "rewardPanel"
        addChild(panel)
        
        let titleLabel = SKLabelNode(fontNamed: "Arial Bold")
        titleLabel.text = "🏆 VICTORY! 🏆"
        titleLabel.fontSize = min(40, panelWidth / 12)
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: panelHeight * 0.34)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        let restLabel = SKLabelNode(fontNamed: "Arial")
        restLabel.text = "You rest and meditate..."
        restLabel.fontSize = min(24, panelWidth / 20)
        restLabel.fontColor = .white
        restLabel.position = CGPoint(x: 0, y: panelHeight * 0.17)
        restLabel.verticalAlignmentMode = .center
        panel.addChild(restLabel)
        
        let healLabel = SKLabelNode(fontNamed: "Arial Bold")
        healLabel.text = "💚 HP & Mana restored!"
        healLabel.fontSize = min(22, panelWidth / 22)
        healLabel.fontColor = SKColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        healLabel.position = CGPoint(x: 0, y: panelHeight * 0.03)
        healLabel.verticalAlignmentMode = .center
        panel.addChild(healLabel)
        
        let xpLabel = SKLabelNode(fontNamed: "Arial Bold")
        xpLabel.text = "⭐️ Gained \(xpGained) XP!"
        xpLabel.fontSize = min(22, panelWidth / 22)
        xpLabel.fontColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        xpLabel.position = CGPoint(x: 0, y: -panelHeight * 0.09)
        xpLabel.verticalAlignmentMode = .center
        panel.addChild(xpLabel)
        
        if leveledUp {
            let levelUpLabel = SKLabelNode(fontNamed: "Arial Bold")
            levelUpLabel.text = "🎉 LEVEL UP! Now Level \(player.level)!"
            levelUpLabel.fontSize = min(26, panelWidth / 20)
            levelUpLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
            levelUpLabel.position = CGPoint(x: 0, y: -panelHeight * 0.20)
            levelUpLabel.verticalAlignmentMode = .center
            panel.addChild(levelUpLabel)
            
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            levelUpLabel.run(SKAction.repeatForever(pulse))
        }
        
        let continueLabel = SKLabelNode(fontNamed: "Arial")
        continueLabel.text = "Click to continue..."
        continueLabel.fontSize = min(18, panelWidth / 27)
        continueLabel.position = CGPoint(x: 0, y: -panelHeight * 0.37)
        continueLabel.verticalAlignmentMode = .center
        panel.addChild(continueLabel)
        
        let appear = SKAction.group([SKAction.fadeIn(withDuration: 0.4), SKAction.scale(to: 1.0, duration: 0.4)])
        panel.run(appear)
        
        playerHPLabel.text = "❤️ HP: \(player.currentHP)/\(player.maxHP)"
        playerManaLabel.text = "💧 Mana: \(player.currentMana)/\(player.maxMana)"
        playerXPLabel.text = "⭐️ XP: \(player.experience) | Level: \(player.level)"
        
        self.rewardCompletionHandler = completion
    }
    
    private func dismissRewardPanel() {
        guard let panel = childNode(withName: "rewardPanel") else {
            rewardCompletionHandler?()
            return
        }
        
        // Ensure full heal/restore
        player.currentHP = player.maxHP
        player.restoreMana()
        
        let disappear = SKAction.group([SKAction.fadeOut(withDuration: 0.3), SKAction.scale(to: 0.5, duration: 0.3)])
        let remove = SKAction.removeFromParent()
        
        panel.run(SKAction.sequence([disappear, remove])) {
            self.rewardCompletionHandler?()
            self.rewardCompletionHandler = nil
        }
    }
    
    private func showRunWarningDialog() {
        // Cancel skill mode if active
        if currentSkillMode != .none {
            currentSkillMode = .none
            updateUI()
        }
        
        guard player.isAlive else { return }
        guard currentEncounter?.isComplete == false else { return }
        
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        
        let panelWidth = min(size.width * 0.7, 500)
        let panelHeight = min(size.height * 0.5, 350)
        
        let overlay = SKShapeNode(rectOf: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = .black
        overlay.alpha = 0.7
        overlay.zPosition = 100
        overlay.name = "runWarningOverlay"
        addChild(overlay)
        
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 20)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        panel.strokeColor = SKColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)
        panel.lineWidth = 4
        panel.zPosition = 101
        panel.name = "runWarningPanel"
        panel.alpha = 0
        panel.setScale(0.5)
        addChild(panel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        panel.run(SKAction.group([fadeIn, scaleUp]))
        
        let titleLabel = SKLabelNode(fontNamed: "Arial Bold")
        titleLabel.text = "⚠️ WARNING ⚠️"
        titleLabel.fontSize = min(32, panelWidth / 15)
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: panelHeight * 0.3)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        let messageLabel = SKLabelNode(fontNamed: "Arial")
        messageLabel.text = "Running skips this encounter,\nbut you will NOT rest or heal!\n\nNext room HP: \(player.currentHP)"
        messageLabel.fontSize = min(20, panelWidth / 25)
        messageLabel.fontColor = .white
        messageLabel.position = CGPoint(x: 0, y: 0)
        messageLabel.verticalAlignmentMode = .center
        messageLabel.numberOfLines = 0
        panel.addChild(messageLabel)
        
        let buttonWidth: CGFloat = 140
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 80
        
        let confirmButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        confirmButton.position = CGPoint(x: -buttonSpacing, y: -panelHeight * 0.35)
        confirmButton.fillColor = SKColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        confirmButton.strokeColor = .white
        confirmButton.name = "confirmRunButton"
        panel.addChild(confirmButton)
        
        let confirmLabel = SKLabelNode(fontNamed: "Arial Bold")
        confirmLabel.text = "RUN"
        confirmLabel.fontSize = 22
        confirmLabel.verticalAlignmentMode = .center
        confirmButton.addChild(confirmLabel)
        
        let cancelButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        cancelButton.position = CGPoint(x: buttonSpacing, y: -panelHeight * 0.35)
        cancelButton.fillColor = SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
        cancelButton.strokeColor = .white
        cancelButton.name = "cancelRunButton"
        panel.addChild(cancelButton)
        
        let cancelLabel = SKLabelNode(fontNamed: "Arial Bold")
        cancelLabel.text = "CANCEL"
        cancelLabel.fontSize = 22
        cancelLabel.verticalAlignmentMode = .center
        cancelButton.addChild(cancelLabel)
    }
    
    private func dismissRunWarningDialog() {
        guard let panel = childNode(withName: "runWarningPanel"),
              let overlay = childNode(withName: "runWarningOverlay") else { return }
        
        let disappear = SKAction.group([SKAction.fadeOut(withDuration: 0.2), SKAction.scale(to: 0.5, duration: 0.2)])
        let remove = SKAction.removeFromParent()
        
        panel.run(SKAction.sequence([disappear, remove]))
        overlay.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), remove]))
        
        rollButton.alpha = 1.0
        checkButton.alpha = (hasRolled && !slottedDice.isEmpty) ? 1.0 : 0.5
        runButton.alpha = 1.0
        updateSkillButtons()
    }
    
    private func runFromEncounter() {
        dismissRunWarningDialog()
        hasRolled = false
        rollCount = 0
        currentSkillMode = .none
        clearAllSlots()
        
        roomNumber += 1
        if roomNumber % 5 == 0 {
            currentEncounter = EncounterGenerator.generateBossEncounter(roomNumber: roomNumber)
        } else {
            currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
        }
        resetDiceToOne()
        
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        resultLabel.text = "⚠️ You ran away! No rest or healing."
        resultLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        updateUI()
        
        let flash = SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.3), SKAction.fadeAlpha(to: 1.0, duration: 0.3)])
        resultLabel.run(SKAction.repeat(flash, count: 2))
    }
    
    private func prepareNextEncounter() {
        rollCount = 0
        hasRolled = false
        currentSkillMode = .none
        roomNumber += 1
        
        player.currentHP = player.maxHP
        player.restoreMana()
        
        if roomNumber % 5 == 0 {
            currentEncounter = EncounterGenerator.generateBossEncounter(roomNumber: roomNumber)
        } else {
            currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
        }
        
        resetDiceToOne()
        
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        resultLabel.text = "Ready for the next challenge!"
        resultLabel.fontColor = .white
        updateUI()
    }
    
    private func startNewGame() {
        childNode(withName: "initialsOverlay")?.removeFromParent()
        childNode(withName: "initialsPanel")?.removeFromParent()
        
        player = Player()
        roomNumber = 1
        rollCount = 0
        hasRolled = false
        isRolling = false
        currentSkillMode = .none
        gameEnded = false
        
        currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
        clearAllSlots()
        resetDiceToOne()
        
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        newGameButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        resultLabel.text = "New game started! Click 'ROLL DICE' to begin!"
        resultLabel.fontColor = .white
        updateUI()
    }
    
    private func updateLeaderboard() {
        for (index, label) in leaderboardLabels.enumerated() {
            if index < highScores.count {
                let score = highScores[index]
                label.text = String(format: "%2d. %@ %4dXP R%d", index + 1, score.initials, score.xp, score.roomNumber)
            } else {
                label.text = String(format: "%2d. --- ----", index + 1)
            }
        }
    }
    
    private func handleGameEnd() {
        let finalXP = player.experience
        let finalRoom = roomNumber
        
        if HighScoreManager.shared.isHighScore(xp: finalXP) {
            showInitialsEntryDialog(xp: finalXP, roomNumber: finalRoom)
        } else {
            resultLabel.text = "💀 Game Over! 💀\nFinal Score: \(finalXP) XP, Room \(finalRoom)\nPress NEW GAME to try again!"
        }
    }
    
    private func showInitialsEntryDialog(xp: Int, roomNumber: Int) {
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        newGameButton.alpha = 0.5
        skillNudgeButton.alpha = 0.3
        skillFlipButton.alpha = 0.3
        skillFocusButton.alpha = 0.3
        
        let panelWidth = min(size.width * 0.5, 400)
        let panelHeight = min(size.height * 0.4, 300)
        
        let overlay = SKShapeNode(rectOf: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = .black
        overlay.alpha = 0.7
        overlay.zPosition = 200
        overlay.name = "initialsOverlay"
        addChild(overlay)
        
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 20)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        panel.strokeColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        panel.lineWidth = 4
        panel.zPosition = 201
        panel.name = "initialsPanel"
        panel.setScale(0.5)
        panel.alpha = 0
        addChild(panel)
        
        let titleLabel = SKLabelNode(fontNamed: "Arial Bold")
        titleLabel.text = "🏆 HIGH SCORE! 🏆"
        titleLabel.fontSize = 28
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 50)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Score: \(xp) XP • Room \(roomNumber)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 90)
        panel.addChild(scoreLabel)
        
        let instructionLabel = SKLabelNode(fontNamed: "Arial")
        instructionLabel.text = "Enter your initials (3 letters):"
        instructionLabel.fontSize = 18
        instructionLabel.fontColor = .white
        instructionLabel.position = CGPoint(x: 0, y: 20)
        panel.addChild(instructionLabel)
        
        let initialsLabel = SKLabelNode(fontNamed: "Courier Bold")
        initialsLabel.text = "___"
        initialsLabel.fontSize = 36
        initialsLabel.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        initialsLabel.position = CGPoint(x: 0, y: -25)
        initialsLabel.name = "initialsDisplay"
        panel.addChild(initialsLabel)
        
        let submitLabel = SKLabelNode(fontNamed: "Arial")
        submitLabel.text = "Press RETURN to submit"
        submitLabel.fontSize = 16
        submitLabel.fontColor = .gray
        submitLabel.position = CGPoint(x: 0, y: -panelHeight / 2 + 40)
        panel.addChild(submitLabel)
        
        panel.run(SKAction.group([SKAction.scale(to: 1.0, duration: 0.3), SKAction.fadeIn(withDuration: 0.3)]))
        
        panel.userData = NSMutableDictionary()
        panel.userData?["xp"] = xp
        panel.userData?["roomNumber"] = roomNumber
        panel.userData?["initials"] = ""
    }
    
    private func dismissInitialsDialog(initials: String, xp: Int, roomNumber: Int) {
        HighScoreManager.shared.addScore(initials: initials, xp: xp, roomNumber: roomNumber)
        highScores = HighScoreManager.shared.loadScores()
        updateLeaderboard()
        
        childNode(withName: "initialsOverlay")?.removeFromParent()
        childNode(withName: "initialsPanel")?.removeFromParent()
        
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        newGameButton.alpha = 1.0
        
        resultLabel.text = "💀 Game Over! 💀\nHigh score saved!\nPress NEW GAME to try again!"
    }
    
    private func activateSkill(_ mode: SkillMode) {
        guard hasRolled, player.isAlive, currentEncounter?.isComplete == false else { return }
        
        if currentSkillMode == mode {
            // Toggle off
            currentSkillMode = .none
            resultLabel.text = "Skill cancelled."
        } else {
            // Activate
            guard player.currentMana >= 1 else {
                resultLabel.text = "Not enough Mana!"
                return
            }
            currentSkillMode = mode
            
            switch mode {
            case .nudge: resultLabel.text = "SELECT A DIE TO NUDGE (+1)"
            case .flip: resultLabel.text = "SELECT A DIE TO FLIP (Opposite)"
            case .focus: resultLabel.text = "SELECT A DIE TO REROLL"
            case .none: break
            }
        }
        updateUI()
    }
    
    private func applySkill(to dice: DiceNode) {
        guard currentSkillMode != .none else { return }
        guard player.useMana(1) else { return }
        
        let oldVal = dice.getValue()
        var msg = ""
        
        switch currentSkillMode {
        case .nudge:
            // Increment by 1, wrap 6->1
            let newVal = oldVal == 6 ? 1 : oldVal + 1
            dice.setValue(newVal)
            msg = "Nudged \(dice.color.displayName) from \(oldVal) to \(newVal)!"
            
        case .flip:
            // Standard die flip: 1<->6, 2<->5, 3<->4. Formula: 7 - value
            let newVal = 7 - oldVal
            dice.setValue(newVal)
            msg = "Flipped \(dice.color.displayName) from \(oldVal) to \(newVal)!"
            
        case .focus:
            // Reroll single die
            msg = "Rerolling \(dice.color.displayName)..."
            dice.rollAnimation { val in
                self.resultLabel.text = "Focused reroll: \(val)!"
            }
            
        case .none: break
        }
        
        // Reset skill mode
        currentSkillMode = .none
        resultLabel.text = msg
        
        // Visual feedback (use public method)
        dice.flash()
        
        updateUI()
    }
    
    private func handleDiceClick(_ dice: DiceNode) {
        guard hasRolled else { return }
        guard !isRolling else { return }
        
        // Check for active skill usage
        if currentSkillMode != .none {
            applySkill(to: dice)
            return
        }
        
        // Normal slotting behavior
        if let slotIndex = slottedDice.first(where: { $0.value == dice })?.key {
            slottedDice.removeValue(forKey: slotIndex)
            if let diceIndex = self.dice.firstIndex(of: dice) {
                let moveBack = SKAction.move(to: originalDicePositions[diceIndex], duration: 0.3)
                dice.run(moveBack)
            }
        } else {
            for i in 0..<6 {
                if slottedDice[i] == nil {
                    slottedDice[i] = dice
                    let moveToSlot = SKAction.move(to: diceSlots[i].position, duration: 0.3)
                    dice.run(moveToSlot)
                    break
                }
            }
        }
        updateUI()
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNodes = nodes(at: location)
        
        if childNode(withName: "runWarningPanel") != nil {
            for node in touchedNodes {
                if node.name == "confirmRunButton" || node.parent?.name == "confirmRunButton" { runFromEncounter(); return }
                if node.name == "cancelRunButton" || node.parent?.name == "cancelRunButton" { dismissRunWarningDialog(); return }
            }
            return
        }
        if childNode(withName: "rewardPanel") != nil { dismissRewardPanel(); return }
        if childNode(withName: "restPanel") != nil { restCompletionHandler?(); return }
        
        for node in touchedNodes {
            if node.name == "newGameButton" || node.parent?.name == "newGameButton" { startNewGame(); return }
            if node.name == "rollButton" || node.parent?.name == "rollButton" { rollAllDice(); return }
            
            if node.name == "checkButton" || node.parent?.name == "checkButton" {
                if hasRolled && !slottedDice.isEmpty { checkGoals() }
                return
            }
            
            if node.name == "runButton" || node.parent?.name == "runButton" { showRunWarningDialog(); return }
            
            // Skills
            if node.name == "skillNudge" || node.parent?.name == "skillNudge" { activateSkill(.nudge); return }
            if node.name == "skillFlip" || node.parent?.name == "skillFlip" { activateSkill(.flip); return }
            if node.name == "skillFocus" || node.parent?.name == "skillFocus" { activateSkill(.focus); return }
            
            // Dice
            if let nodeName = node.name, nodeName.hasPrefix("dice_") {
                if let dice = node as? DiceNode { handleDiceClick(dice) }
                else if let dice = node.parent as? DiceNode { handleDiceClick(dice) }
                return
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let panel = childNode(withName: "initialsPanel") as? SKShapeNode,
           let initialsLabel = panel.childNode(withName: "initialsDisplay") as? SKLabelNode,
           let userData = panel.userData {
            
            var currentInitials = userData["initials"] as? String ?? ""
            
            if event.keyCode == 36 { // Return
                if currentInitials.count == 3 {
                    let xp = userData["xp"] as? Int ?? 0
                    let room = userData["roomNumber"] as? Int ?? 0
                    dismissInitialsDialog(initials: currentInitials, xp: xp, roomNumber: room)
                }
                return
            }
            
            if event.keyCode == 51 { // Delete
                if !currentInitials.isEmpty {
                    currentInitials.removeLast()
                    userData["initials"] = currentInitials
                    let display = currentInitials.padding(toLength: 3, withPad: "_", startingAt: 0)
                    initialsLabel.text = display.uppercased()
                }
                return
            }
            
            if let characters = event.characters, currentInitials.count < 3 {
                let filtered = characters.uppercased().filter { $0.isLetter }
                if let char = filtered.first {
                    currentInitials.append(char)
                    userData["initials"] = currentInitials
                    let display = currentInitials.padding(toLength: 3, withPad: "_", startingAt: 0)
                    initialsLabel.text = display.uppercased()
                }
            }
            return
        }
        
        if childNode(withName: "rewardPanel") != nil { dismissRewardPanel(); return }
        if childNode(withName: "runWarningPanel") != nil {
            if event.keyCode == 53 { dismissRunWarningDialog() }
            else if event.keyCode == 36 { runFromEncounter() }
            return
        }
        if childNode(withName: "restPanel") != nil { restCompletionHandler?(); return }
        
        // Shortcuts
        if event.keyCode == 49 { rollAllDice() } // Space
        if event.keyCode == 36 { if hasRolled && !slottedDice.isEmpty { checkGoals() } } // Return
        if event.keyCode == 15 { if player.isAlive && currentEncounter?.isComplete == false { showRunWarningDialog() } } // R
        
        // Skill Shortcuts?
        if event.keyCode == 18 { activateSkill(.nudge) } // 1
        if event.keyCode == 19 { activateSkill(.flip) }  // 2
        if event.keyCode == 20 { activateSkill(.focus) } // 3
    }
    
    override func update(_ currentTime: TimeInterval) {}
}
