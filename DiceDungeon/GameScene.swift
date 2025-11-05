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
    
    // UI elements
    private var dice: [DiceNode] = []
    private var diceSlots: [SKShapeNode] = []
    private var slottedDice: [Int: DiceNode] = [:] // slot index -> dice node
    private var rollButton: SKShapeNode!
    private var rollButtonLabel: SKLabelNode!
    private var checkButton: SKShapeNode!
    private var checkButtonLabel: SKLabelNode!
    private var runButton: SKShapeNode!
    private var runButtonLabel: SKLabelNode!
    private var newGameButton: SKShapeNode!
    private var newGameButtonLabel: SKLabelNode!
    private var resultLabel: SKLabelNode!
    private var playerHPLabel: SKLabelNode!
    private var playerXPLabel: SKLabelNode!
    private var monsterInfoLabel: SKLabelNode!
    private var monsterHPLabel: SKLabelNode!
    private var goalsLabel: SKLabelNode!
    private var roomNumberLabel: SKLabelNode!
    private var rollCountLabel: SKLabelNode!
    private var titleLabel: SKLabelNode!
    private var leaderboardTitleLabel: SKLabelNode!
    private var leaderboardLabels: [SKLabelNode] = []
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
        static let playerXPYOffset: CGFloat = 90
        static let leaderboardYOffset: CGFloat = 207  // Start of leaderboard below player XP (moved down ~1 inch)
        static let leaderboardLineHeight: CGFloat = 20  // Space between leaderboard entries
        static let monsterStatsYOffset: CGFloat = 60
        static let monsterHPYOffset: CGFloat = 90
        static let goalsYOffset: CGFloat = 230  // Goals list - increased spacing to prevent overlap
        static let buttonYOffset: CGFloat = 80
        static let resultYOffset: CGFloat = 160
        static let buttonWidth: CGFloat = 180
        static let buttonHeight: CGFloat = 60
        static let buttonSpacing: CGFloat = 100
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        
        // Initialize game
        player = Player()
        currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
        rollCount = 0
        hasRolled = false
        
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
            label.text = String(format: "%2d. --- ----", i + 1)  // Show placeholder immediately
            addChild(label)
            leaderboardLabels.append(label)
            
            print("DEBUG setupUI: Created leaderboard label [\(i)] at position \(label.position)")
        }
        
        // Load high scores
        print("DEBUG setupUI: Loading high scores...")
        highScores = HighScoreManager.shared.loadScores()
        print("DEBUG setupUI: Loaded \(highScores.count) scores, updating leaderboard...")
        updateLeaderboard()
        
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
        
        // Goals label (below monster info on the right side)
        goalsLabel = SKLabelNode(fontNamed: "Arial")
        goalsLabel.fontSize = smallFontSize
        goalsLabel.fontColor = SKColor(red: 1.0, green: 1.0, blue: 0.6, alpha: 1.0)
        goalsLabel.position = CGPoint(x: size.width - Layout.padding - 100, y: size.height - Layout.goalsYOffset)
        goalsLabel.numberOfLines = 0
        goalsLabel.preferredMaxLayoutWidth = 400  // Limit width for right-side display
        goalsLabel.horizontalAlignmentMode = .right
        addChild(goalsLabel)
        
        // Calculate positions for 3 evenly spaced centered buttons
        let buttonSpacingFor3 = Layout.buttonWidth + 40  // Button width + gap between buttons
        let totalWidth = buttonSpacingFor3 * 2  // Space for 3 buttons (2 gaps between them)
        let startX = (size.width - totalWidth) / 2  // Start position to center the group
        
        // Roll button (left of the three)
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
        rollButtonLabel.position = CGPoint(x: 0, y: 0)
        rollButton.addChild(rollButtonLabel)
        
        // Check button (center of the three)
        checkButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        checkButton.position = CGPoint(x: startX + buttonSpacingFor3, y: Layout.buttonYOffset)
        checkButton.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        checkButton.strokeColor = .white
        checkButton.lineWidth = 3
        checkButton.name = "checkButton"
        checkButton.alpha = 0.5 // Disabled by default
        addChild(checkButton)
        
        checkButtonLabel = SKLabelNode(fontNamed: "Arial Bold")
        checkButtonLabel.text = "CHECK"
        checkButtonLabel.fontSize = min(22, normalFontSize + 2)
        checkButtonLabel.fontColor = .white
        checkButtonLabel.verticalAlignmentMode = .center
        checkButtonLabel.position = CGPoint(x: 0, y: 0)
        checkButton.addChild(checkButtonLabel)
        
        // Run button (right of the three)
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
        runButtonLabel.position = CGPoint(x: 0, y: 0)
        runButton.addChild(runButtonLabel)
        
        // New Game button (top left corner, below player stats)
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
        newGameButtonLabel.position = CGPoint(x: 0, y: 0)
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
    
    private func setupDice() {
        // Scale dice based on scene size
        let sceneWidth = max(size.width, Layout.minWidth)
        _ = max(size.height, Layout.minHeight) // For potential future use
        
        // Calculate dice spacing and size based on available space
        let diceSpacing = min(110, sceneWidth / 8)
        let dicePerRow: CGFloat = 3
        
        // Calculate centered positions
        let totalWidth = (dicePerRow - 1) * diceSpacing
        let startX = (size.width - totalWidth) / 2
        
        // Position dice in the middle vertical space
        let topRowY = size.height / 2 + diceSpacing * 0.55
        let bottomRowY = size.height / 2 - diceSpacing * 0.55
        
        // Top row (3 dice) - Red, Orange, Yellow
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
        
        // Bottom row (3 dice) - Green, Blue, Purple
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
        // Scale slots based on scene size
        let sceneWidth = max(size.width, Layout.minWidth)
        
        // Create 6 slots below the dice for placing dice
        let slotSize: CGFloat = min(90, sceneWidth / 10)
        let slotSpacing = min(100, sceneWidth / 9)
        let slotsPerRow: CGFloat = 6
        
        // Calculate centered positions
        let totalWidth = (slotsPerRow - 1) * slotSpacing
        let startX = (size.width - totalWidth) / 2
        
        // Position slots below center, scaled by scene height
        let slotY = size.height / 2 - min(180, size.height / 3.5)
        
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
        playerXPLabel.text = "⭐️ XP: \(player.experience) | Level: \(player.level)"
        
        // Update room number
        roomNumberLabel.text = "Room \(roomNumber)"
        
        // Update roll count
        rollCountLabel.text = "Rolls: \(rollCount) | Damage taken: \((rollCount - 1) * 10) HP"
        if rollCount <= 1 {
            rollCountLabel.fontColor = SKColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        } else {
            rollCountLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        }
        
        // Update monster info
        if let encounter = currentEncounter, let monster = encounter.currentMonster {
            monsterInfoLabel.text = "\(monster.type.emoji) \(monster.type.displayName)"
            
            // Show progress: completed goals / total goals
            let completed = monster.goalsCompleted.count
            let total = monster.goals.count
            monsterHPLabel.text = "Goals: \(completed)/\(total)"
            
            // Display remaining goals (only show incomplete ones)
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
        
        // Update check button state
        if hasRolled && !slottedDice.isEmpty {
            checkButton.alpha = 1.0
        } else {
            checkButton.alpha = 0.5
        }
        
        // Update run button state (always enabled during active encounter)
        if !player.isAlive || currentEncounter?.isComplete == true {
            runButton.alpha = 0.5
        } else {
            runButton.alpha = 1.0
        }
        
        // Update result label
        if !player.isAlive {
            // Check if we haven't already shown the initials dialog
            if childNode(withName: "initialsPanel") == nil {
                resultLabel.text = "💀 You have been defeated! 💀\nFinal Score: Room \(roomNumber), \(player.experience) XP"
                rollButton.alpha = 0.5
                checkButton.alpha = 0.5
                runButton.alpha = 0.5
                
                // Trigger high score entry after a brief delay
                let wait = SKAction.wait(forDuration: 1.0)
                let showDialog = SKAction.run { [weak self] in
                    self?.handleGameEnd()
                }
                self.run(SKAction.sequence([wait, showDialog]))
            }
        } else if currentEncounter?.isComplete == true {
            resultLabel.text = "🎉 Room cleared! Health restored to full!"
        } else if !hasRolled {
            resultLabel.text = "Click 'ROLL DICE' or press SPACE to roll all dice!"
        } else if slottedDice.isEmpty {
            resultLabel.text = "Click dice to place them in slots, then press 'CHECK' (or RETURN) or 'ROLL AGAIN'"
        } else {
            resultLabel.text = "Place more dice in slots or press 'CHECK' (RETURN). Reroll unslotted dice anytime!"
        }
    }
    
    private func rollAllDice() {
        guard !isRolling else { return }
        guard player.isAlive else { return }
        guard currentEncounter?.isComplete == false else { return }
        
        // Increment roll count ONLY if we've already rolled once
        if hasRolled {
            rollCount += 1
            
            // Take damage for additional rolls (10 HP per roll after the first)
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
        
        // Determine which dice to roll:
        // - If no dice are slotted, roll all dice and clear slots
        // - If some dice are slotted, only roll the unslotted dice
        let shouldClearSlots = slottedDice.isEmpty
        
        if shouldClearSlots {
            // Clear all slots
            clearAllSlots()
        }
        
        // Get indices of dice that should be rolled (not slotted)
        var diceToRoll: [Int] = []
        for (index, dice) in self.dice.enumerated() {
            // Check if this dice is slotted
            let isSlotted = slottedDice.values.contains(dice)
            if !isSlotted {
                diceToRoll.append(index)
            }
        }
        
        var completedDice = 0
        let totalDiceToRoll = diceToRoll.count
        
        for diceIndex in diceToRoll {
            let dice = self.dice[diceIndex]
            
            // Stagger the start of each dice roll slightly
            let delay = Double(diceToRoll.firstIndex(of: diceIndex) ?? 0) * 0.1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                dice.rollAnimation { value in
                    completedDice += 1
                    
                    // When all dice are done rolling
                    if completedDice == totalDiceToRoll {
                        self.isRolling = false
                        self.rollButtonLabel.text = "ROLL AGAIN"
                        self.rollButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
                        self.updateUI()
                    }
                }
            }
        }
        
        // Handle edge case where all dice are slotted
        if totalDiceToRoll == 0 {
            isRolling = false
            rollButtonLabel.text = "ROLL AGAIN"
            rollButton.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        }
    }
    
    private func clearAllSlots() {
        // Move all dice back to original positions
        for (_, dice) in slottedDice {
            if let diceIndex = self.dice.firstIndex(of: dice) {
                let moveBack = SKAction.move(to: originalDicePositions[diceIndex], duration: 0.3)
                dice.run(moveBack)
            }
        }
        slottedDice.removeAll()
    }
    
    private func resetDiceToOne() {
        // Reset all dice to show 1 pip
        for dice in self.dice {
            dice.setValue(1)
        }
    }
    
    private func checkGoals() {
        guard hasRolled else {
            print("DEBUG: Check failed - hasRolled is false")
            return
        }
        guard !slottedDice.isEmpty else {
            print("DEBUG: Check failed - no slotted dice")
            return
        }
        guard let encounter = currentEncounter,
              let monster = encounter.currentMonster else {
            print("DEBUG: Check failed - no encounter or monster")
            return
        }
        
        print("DEBUG: Checking goals with \(slottedDice.count) slotted dice")
        
        // Build results from slotted dice
        var results: [DiceResult] = []
        for i in 0..<6 {
            if let dice = slottedDice[i] {
                let result = DiceResult(color: dice.color, value: dice.getValue())
                results.append(result)
                print("DEBUG: Slot \(i): \(dice.color.displayName) = \(dice.getValue())")
            }
        }
        
        print("DEBUG: Total results passed to goals: \(results.count)")
        print("DEBUG: Results summary: \(results.map { "\($0.color.displayName):\($0.value)" }.joined(separator: ", "))")
        print("DEBUG: Monster has \(monster.goals.count) goals")
        
        // Check which goals are met
        var goalsMet: [Int] = [] // Track indices of met goals
        for (index, goal) in monster.goals.enumerated() {
            // Skip already completed goals
            if monster.goalsCompleted.contains(index) {
                print("DEBUG: Goal \(index) '\(goal.description)' already completed")
                continue
            }
            
            let isMet = goal.isMet(by: results)
            print("DEBUG: Goal \(index) '\(goal.description)' met: \(isMet)")
            if isMet {
                goalsMet.append(index)
            }
        }
        
        print("DEBUG: \(goalsMet.count) new goals met")
        
        var message = ""
        
        // Display slotted values
        let valuesText = results.map { "\($0.color.displayName): \($0.value)" }.joined(separator: ", ")
        message += "Slotted: \(valuesText)\n\n"
        
        if !goalsMet.isEmpty {
            // Mark goals as completed
            goalsMet.forEach { monster.markGoalCompleted(at: $0) }
            
            message += "✅ Goals completed!\n"
            goalsMet.forEach { index in
                message += "• \(monster.goals[index].description)\n"
            }
            
            // Check if monster is now defeated (all goals complete)
            if monster.isDefeated {
                message += "\n💥 ALL GOALS COMPLETE! Monster defeated!"
                
                print("DEBUG: Monster defeated, checking encounter.isComplete...")
                // Check if all monsters in room are defeated
                if encounter.isComplete {
                    print("DEBUG: Encounter IS complete - calling handleEncounterComplete")
                    // All monsters defeated! Show death animation and reward sequence
                    handleEncounterComplete()
                    return
                } else {
                    print("DEBUG: Encounter NOT complete - more monsters remain")
                    // More monsters remain in this encounter
                    message += "\n\n🎯 \(monster.type.displayName) defeated!"
                    handleMonsterDefeated(message: message)
                    return
                }
            } else {
                // Monster still has goals remaining
                let remaining = monster.remainingGoals.count
                message += "\n\n🎯 Progress! \(remaining) goal(s) remaining!"
                hasRolled = false
                clearAllSlots()
                rollButtonLabel.text = "ROLL DICE"
            }
        } else {
            // No goals met
            message += "❌ No new goals achieved! Try different dice combinations."
            
            // Don't clear the slots, let them try again
        }
        
        resultLabel.text = message
        // Don't call updateUI() here as it will overwrite the message
        // Instead, update only the specific UI elements that need updating
        playerHPLabel.text = "❤️ HP: \(player.currentHP)/\(player.maxHP)"
        playerXPLabel.text = "⭐️ XP: \(player.experience) | Level: \(player.level)"
        
        if let encounter = currentEncounter, let monster = encounter.currentMonster {
            monsterInfoLabel.text = "\(monster.type.emoji) \(monster.type.displayName)"
            let completed = monster.goalsCompleted.count
            let total = monster.goals.count
            monsterHPLabel.text = "Goals: \(completed)/\(total)"
        }
        
        // Update check button state
        if hasRolled && !slottedDice.isEmpty {
            checkButton.alpha = 1.0
        } else {
            checkButton.alpha = 0.5
        }
    }
    
    private func handleEncounterComplete() {
        guard let encounter = currentEncounter else {
            print("DEBUG handleEncounterComplete: ERROR - currentEncounter is nil!")
            return
        }
        
        print("DEBUG handleEncounterComplete: Starting - Room \(roomNumber), Encounter room: \(encounter.roomNumber), HP: \(player.currentHP)/\(player.maxHP), RollCount: \(rollCount)")
        print("DEBUG handleEncounterComplete: Encounter has \(encounter.monsters.count) monsters, all defeated: \(encounter.isComplete)")
        
        // Reset roll count since encounter is complete
        rollCount = 0
        hasRolled = false
        
        // IMMEDIATELY heal player to full when encounter is won
        player.currentHP = player.maxHP
        
        print("DEBUG handleEncounterComplete: After immediate heal - HP: \(player.currentHP)/\(player.maxHP), RollCount reset to: \(rollCount)")
        
        // Disable buttons during animation
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        
        // Clear slots
        clearAllSlots()
        
        print("DEBUG handleEncounterComplete: About to play death animation")
        
        // Play monster death animation
        playMonsterDeathAnimation {
            print("DEBUG handleEncounterComplete: Death animation complete, showing reward")
            // After death animation, show rest and reward
            self.showRestAndReward(encounter: encounter) {
                print("DEBUG handleEncounterComplete: Reward dismissed, preparing next encounter")
                // After rest, prepare for next room
                self.prepareNextEncounter()
            }
        }
    }
    
    private func handleMonsterDefeated(message: String) {
        // A monster was defeated but more remain in the encounter
        // Disable buttons during animation
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        
        // Clear slots
        clearAllSlots()
        hasRolled = false
        
        // Show brief defeat message and rest
        showMonsterDefeatedTransition(message: message) {
            // Heal player and prepare for next monster
            self.restBetweenMonsters()
        }
    }
    
    private func showMonsterDefeatedTransition(message: String, completion: @escaping () -> Void) {
        // Calculate scaled font size
        let fontSize = min(48, size.width / 20)
        
        // Create a brief victory message
        let deathLabel = SKLabelNode(fontNamed: "Arial Bold")
        deathLabel.text = "💀 DEFEATED! 💀"
        deathLabel.fontSize = fontSize
        deathLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        deathLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        deathLabel.alpha = 0
        deathLabel.setScale(0.5)
        addChild(deathLabel)
        
        // Flash the monster info
        let flashIn = SKAction.fadeAlpha(to: 0.3, duration: 0.15)
        let flashOut = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
        let flash = SKAction.sequence([flashIn, flashOut])
        let flashRepeat = SKAction.repeat(flash, count: 2)
        monsterInfoLabel.run(flashRepeat)
        monsterHPLabel.run(flashRepeat)
        
        // Animate death label (shorter than full encounter complete)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let appear = SKAction.group([fadeIn, scaleUp])
        
        let wait = SKAction.wait(forDuration: 0.5)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let disappear = fadeOut
        
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([appear, wait, disappear, remove])
        deathLabel.run(sequence) {
            completion()
        }
    }
    
    private func restBetweenMonsters() {
        guard let encounter = currentEncounter else { return }
        
        // NO healing between monsters - player maintains their HP
        // Healing only happens when the entire encounter is complete
        
        // Get next monster info
        guard let nextMonster = encounter.currentMonster else {
            // This shouldn't happen, but just in case
            handleEncounterComplete()
            return
        }
        
        // Calculate scaled panel size
        let panelWidth = min(450, size.width * 0.6)
        let panelHeight = min(200, size.height * 0.33)
        
        // Show brief rest message
        let restPanel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 15)
        restPanel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        restPanel.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.3, alpha: 0.95)
        restPanel.strokeColor = SKColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        restPanel.lineWidth = 3
        restPanel.alpha = 0
        restPanel.setScale(0.8)
        restPanel.name = "restPanel"
        addChild(restPanel)
        
        // Calculate font sizes
        let titleFontSize = min(32, panelWidth / 14)
        let largeFontSize = min(24, panelWidth / 18)
        let mediumFontSize = min(20, panelWidth / 22)
        let smallFontSize = min(16, panelWidth / 28)
        
        // Rest message
        let restLabel = SKLabelNode(fontNamed: "Arial Bold")
        restLabel.text = "⚔️ One Down! ⚔️"
        restLabel.fontSize = titleFontSize
        restLabel.fontColor = SKColor(red: 1.0, green: 1.0, blue: 0.6, alpha: 1.0)
        restLabel.position = CGPoint(x: 0, y: panelHeight * 0.25)
        restLabel.verticalAlignmentMode = .center
        restPanel.addChild(restLabel)
        
        // Status message
        let statusLabel = SKLabelNode(fontNamed: "Arial Bold")
        statusLabel.text = "💪 Prepare for the next fight!"
        statusLabel.fontSize = largeFontSize
        statusLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        statusLabel.position = CGPoint(x: 0, y: panelHeight * 0.025)
        statusLabel.verticalAlignmentMode = .center
        restPanel.addChild(statusLabel)
        
        // Next monster message
        let nextLabel = SKLabelNode(fontNamed: "Arial")
        nextLabel.text = "Next: \(nextMonster.type.emoji) \(nextMonster.type.displayName)"
        nextLabel.fontSize = mediumFontSize
        nextLabel.fontColor = SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
        nextLabel.position = CGPoint(x: 0, y: -panelHeight * 0.175)
        nextLabel.verticalAlignmentMode = .center
        restPanel.addChild(nextLabel)
        
        // Continue message
        let continueLabel = SKLabelNode(fontNamed: "Arial")
        continueLabel.text = "Press SPACE or click to continue..."
        continueLabel.fontSize = smallFontSize
        continueLabel.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        continueLabel.position = CGPoint(x: 0, y: -panelHeight * 0.35)
        continueLabel.verticalAlignmentMode = .center
        restPanel.addChild(continueLabel)
        
        // Animate panel appearance
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let appear = SKAction.group([fadeIn, scaleUp])
        
        restPanel.run(appear)
        
        // Update UI
        updateUI()
        
        // Store completion handler for when player clicks/presses space
        self.restCompletionHandler = {
            self.dismissRestPanel()
        }
    }
    
    private func dismissRestPanel() {
        guard let panel = childNode(withName: "restPanel") else { return }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
        let disappear = SKAction.group([fadeOut, scaleDown])
        let remove = SKAction.removeFromParent()
        
        panel.run(SKAction.sequence([disappear, remove])) {
            // Continue to next monster
            self.continueToNextMonster()
        }
    }
    
    private func continueToNextMonster() {
        // Reset for next monster in the same encounter
        hasRolled = false
        rollCount = 0
        clearAllSlots()
        
        // Re-enable buttons
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        // Update UI to show next monster
        resultLabel.text = "Ready to face the next monster!"
        updateUI()
        
        // Clear the handler
        restCompletionHandler = nil
    }
    
    private func playMonsterDeathAnimation(completion: @escaping () -> Void) {
        // Calculate scaled font size
        let fontSize = min(64, size.width / 15)
        
        // Create a visual effect for monster death
        let deathLabel = SKLabelNode(fontNamed: "Arial Bold")
        deathLabel.text = "💀 DEFEATED! 💀"
        deathLabel.fontSize = fontSize
        deathLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        deathLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        deathLabel.alpha = 0
        deathLabel.setScale(0.5)
        addChild(deathLabel)
        
        // Flash the monster info
        let flashIn = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
        let flashOut = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        let flash = SKAction.sequence([flashIn, flashOut])
        let flashRepeat = SKAction.repeat(flash, count: 3)
        monsterInfoLabel.run(flashRepeat)
        monsterHPLabel.run(flashRepeat)
        
        // Animate death label
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.3)
        let appear = SKAction.group([fadeIn, scaleUp])
        
        let wait = SKAction.wait(forDuration: 1.0)
        
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let disappear = SKAction.group([scaleDown, fadeOut])
        
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([appear, wait, disappear, remove])
        deathLabel.run(sequence) {
            completion()
        }
    }
    
    private func showRestAndReward(encounter: Encounter, completion: @escaping () -> Void) {
        // Calculate rewards
        let xpGained = encounter.totalXPValue
        _ = encounter.healAmount // Calculated but not used (healing is always full)
        let oldLevel = player.level
        
        print("DEBUG showRestAndReward: Before XP - HP: \(player.currentHP)/\(player.maxHP), Level: \(player.level)")
        
        // Apply rewards - gain XP first (may level up and increase maxHP)
        player.gainExperience(xpGained)
        
        let leveledUp = player.level > oldLevel
        
        print("DEBUG showRestAndReward: After XP - HP: \(player.currentHP)/\(player.maxHP), Level: \(player.level), Leveled up: \(leveledUp)")
        
        // Then restore to full HP (after any level up has occurred)
        // Note: checkLevelUp() already heals to full, but we do it again to be safe
        player.currentHP = player.maxHP
        
        print("DEBUG showRestAndReward: After heal - HP: \(player.currentHP)/\(player.maxHP)")
        
        // Calculate scaled panel size
        let panelWidth = min(500, size.width * 0.7)
        let panelHeight = min(350, size.height * 0.5)
        
        // Create rest/reward panel
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 20)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = SKColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 0.95)
        panel.strokeColor = SKColor(red: 0.8, green: 0.8, blue: 0.3, alpha: 1.0)
        panel.lineWidth = 4
        panel.alpha = 0
        panel.setScale(0.5)
        panel.name = "rewardPanel"
        addChild(panel)
        
        // Calculate font sizes
        let titleFontSize = min(40, panelWidth / 12)
        let largeFontSize = min(24, panelWidth / 20)
        let mediumFontSize = min(22, panelWidth / 22)
        let smallFontSize = min(18, panelWidth / 27)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Arial Bold")
        titleLabel.text = "🏆 VICTORY! 🏆"
        titleLabel.fontSize = titleFontSize
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: panelHeight * 0.34)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        // Rest message
        let restLabel = SKLabelNode(fontNamed: "Arial")
        restLabel.text = "You take a moment to rest..."
        restLabel.fontSize = largeFontSize
        restLabel.fontColor = .white
        restLabel.position = CGPoint(x: 0, y: panelHeight * 0.17)
        restLabel.verticalAlignmentMode = .center
        panel.addChild(restLabel)
        
        // Rewards
        let healLabel = SKLabelNode(fontNamed: "Arial Bold")
        healLabel.text = "💚 Health restored to full!"
        healLabel.fontSize = mediumFontSize
        healLabel.fontColor = SKColor(red: 0.5, green: 1.0, blue: 0.5, alpha: 1.0)
        healLabel.position = CGPoint(x: 0, y: panelHeight * 0.03)
        healLabel.verticalAlignmentMode = .center
        panel.addChild(healLabel)
        
        let xpLabel = SKLabelNode(fontNamed: "Arial Bold")
        xpLabel.text = "⭐️ Gained \(xpGained) XP!"
        xpLabel.fontSize = mediumFontSize
        xpLabel.fontColor = SKColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        xpLabel.position = CGPoint(x: 0, y: -panelHeight * 0.09)
        xpLabel.verticalAlignmentMode = .center
        panel.addChild(xpLabel)
        
        // Level up message (if applicable)
        if leveledUp {
            let levelUpLabel = SKLabelNode(fontNamed: "Arial Bold")
            levelUpLabel.text = "🎉 LEVEL UP! Now Level \(player.level)!"
            levelUpLabel.fontSize = min(26, mediumFontSize + 4)
            levelUpLabel.fontColor = SKColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
            levelUpLabel.position = CGPoint(x: 0, y: -panelHeight * 0.20)
            levelUpLabel.verticalAlignmentMode = .center
            panel.addChild(levelUpLabel)
            
            // Animate level up label
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            levelUpLabel.run(SKAction.repeatForever(pulse))
        }
        
        // Continue prompt
        let continueLabel = SKLabelNode(fontNamed: "Arial")
        continueLabel.text = "Press SPACE or click to continue..."
        continueLabel.fontSize = smallFontSize
        continueLabel.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        continueLabel.position = CGPoint(x: 0, y: -panelHeight * 0.37)
        continueLabel.verticalAlignmentMode = .center
        panel.addChild(continueLabel)
        
        // Animate panel appearance
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.4)
        let appear = SKAction.group([fadeIn, scaleUp])
        
        panel.run(appear)
        
        // Update only player stats (not room number - that will update in prepareNextEncounter)
        playerHPLabel.text = "❤️ HP: \(player.currentHP)/\(player.maxHP)"
        playerXPLabel.text = "⭐️ XP: \(player.experience) | Level: \(player.level)"
        
        // Store completion handler for when player clicks/presses space
        self.rewardCompletionHandler = completion
    }
    
    private func dismissRewardPanel() {
        guard let panel = childNode(withName: "rewardPanel") else {
            print("DEBUG dismissRewardPanel: ERROR - rewardPanel not found!")
            // Even if panel is missing, try to call the handler and continue
            if let handler = self.rewardCompletionHandler {
                print("DEBUG dismissRewardPanel: Panel missing but calling handler anyway")
                handler()
                self.rewardCompletionHandler = nil
            }
            return
        }
        
        print("DEBUG dismissRewardPanel: Starting - Room \(roomNumber), HP: \(player.currentHP)/\(player.maxHP)")
        
        // Ensure healing is applied before moving on
        player.currentHP = player.maxHP
        
        print("DEBUG dismissRewardPanel: After defensive heal - HP: \(player.currentHP)/\(player.maxHP)")
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.3)
        let disappear = SKAction.group([fadeOut, scaleDown])
        let remove = SKAction.removeFromParent()
        
        panel.run(SKAction.sequence([disappear, remove])) {
            print("DEBUG dismissRewardPanel: Panel animation complete")
            if let handler = self.rewardCompletionHandler {
                print("DEBUG dismissRewardPanel: Calling completion handler")
                handler()
                self.rewardCompletionHandler = nil
            } else {
                print("DEBUG dismissRewardPanel: ERROR - No completion handler found!")
            }
        }
    }
    
    private func showRunWarningDialog() {
        guard player.isAlive else { return }
        guard currentEncounter?.isComplete == false else { return }
        
        // Disable buttons during dialog
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        
        // Calculate dimensions
        let panelWidth = min(size.width * 0.7, 500)
        let panelHeight = min(size.height * 0.5, 350)
        
        // Create semi-transparent overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = SKColor.black
        overlay.alpha = 0.7
        overlay.zPosition = 100
        overlay.name = "runWarningOverlay"
        addChild(overlay)
        
        // Create panel
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
        
        // Animate in
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        panel.run(SKAction.group([fadeIn, scaleUp]))
        
        // Calculate font sizes
        let titleFontSize = min(32, panelWidth / 15)
        let normalFontSize = min(20, panelWidth / 25)
        let buttonFontSize = min(22, panelWidth / 22)
        
        // Warning title
        let titleLabel = SKLabelNode(fontNamed: "Arial Bold")
        titleLabel.text = "⚠️ WARNING ⚠️"
        titleLabel.fontSize = titleFontSize
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: panelHeight * 0.3)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        // Warning message
        let messageLabel = SKLabelNode(fontNamed: "Arial")
        messageLabel.text = "Running will skip this encounter,\nbut you will NOT rest or heal!\n\nYou'll face the next room\nwith your current HP."
        messageLabel.fontSize = normalFontSize
        messageLabel.fontColor = .white
        messageLabel.position = CGPoint(x: 0, y: 0)
        messageLabel.verticalAlignmentMode = .center
        messageLabel.numberOfLines = 0
        messageLabel.preferredMaxLayoutWidth = panelWidth * 0.85
        panel.addChild(messageLabel)
        
        // Current HP reminder
        let hpLabel = SKLabelNode(fontNamed: "Arial Bold")
        hpLabel.text = "Current HP: \(player.currentHP)/\(player.maxHP)"
        hpLabel.fontSize = normalFontSize
        hpLabel.fontColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        hpLabel.position = CGPoint(x: 0, y: -panelHeight * 0.2)
        hpLabel.verticalAlignmentMode = .center
        panel.addChild(hpLabel)
        
        let buttonWidth: CGFloat = 140
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 80
        
        // Confirm button (left)
        let confirmButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        confirmButton.position = CGPoint(x: -buttonSpacing, y: -panelHeight * 0.35)
        confirmButton.fillColor = SKColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        confirmButton.strokeColor = .white
        confirmButton.lineWidth = 2
        confirmButton.name = "confirmRunButton"
        panel.addChild(confirmButton)
        
        let confirmLabel = SKLabelNode(fontNamed: "Arial Bold")
        confirmLabel.text = "RUN"
        confirmLabel.fontSize = buttonFontSize
        confirmLabel.fontColor = .white
        confirmLabel.verticalAlignmentMode = .center
        confirmLabel.position = CGPoint(x: 0, y: 0)
        confirmButton.addChild(confirmLabel)
        
        // Cancel button (right)
        let cancelButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        cancelButton.position = CGPoint(x: buttonSpacing, y: -panelHeight * 0.35)
        cancelButton.fillColor = SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
        cancelButton.strokeColor = .white
        cancelButton.lineWidth = 2
        cancelButton.name = "cancelRunButton"
        panel.addChild(cancelButton)
        
        let cancelLabel = SKLabelNode(fontNamed: "Arial Bold")
        cancelLabel.text = "CANCEL"
        cancelLabel.fontSize = buttonFontSize
        cancelLabel.fontColor = .white
        cancelLabel.verticalAlignmentMode = .center
        cancelLabel.position = CGPoint(x: 0, y: 0)
        cancelButton.addChild(cancelLabel)
    }
    
    private func dismissRunWarningDialog() {
        guard let panel = childNode(withName: "runWarningPanel"),
              let overlay = childNode(withName: "runWarningOverlay") else { return }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scaleDown = SKAction.scale(to: 0.5, duration: 0.2)
        let disappear = SKAction.group([fadeOut, scaleDown])
        let remove = SKAction.removeFromParent()
        
        panel.run(SKAction.sequence([disappear, remove]))
        overlay.run(SKAction.sequence([fadeOut, remove]))
        
        // Re-enable buttons
        rollButton.alpha = 1.0
        if hasRolled && !slottedDice.isEmpty {
            checkButton.alpha = 1.0
        } else {
            checkButton.alpha = 0.5
        }
        runButton.alpha = 1.0
    }
    
    private func runFromEncounter() {
        // Dismiss the warning dialog
        dismissRunWarningDialog()
        
        // Clear the current state
        hasRolled = false
        rollCount = 0
        clearAllSlots()
        
        // Move to next room WITHOUT healing
        roomNumber += 1
        
        // Generate new encounter
        if roomNumber % 5 == 0 {
            // Every 5th room is a boss
            currentEncounter = EncounterGenerator.generateBossEncounter(roomNumber: roomNumber)
        } else {
            currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
        }
        
        // Reset dice to show 1 pip for new encounter
        resetDiceToOne()
        
        // Reset buttons
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        // Update UI to reflect new room (with no healing)
        resultLabel.text = "⚠️ You ran away! No rest or healing. Good luck!"
        resultLabel.fontColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        updateUI()
        
        // Flash the result message
        let flash = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ])
        resultLabel.run(SKAction.repeat(flash, count: 2))
    }
    
    private func prepareNextEncounter() {
        print("DEBUG prepareNextEncounter: START - Current room: \(roomNumber)")
        
        // Reset for next room
        rollCount = 0
        hasRolled = false
        roomNumber += 1
        
        print("DEBUG prepareNextEncounter: Room incremented to: \(roomNumber)")
        print("DEBUG prepareNextEncounter: Before heal - HP: \(player.currentHP)/\(player.maxHP), Room: \(roomNumber)")
        
        // Ensure player is fully healed (defensive check)
        player.currentHP = player.maxHP
        
        print("DEBUG prepareNextEncounter: After heal - HP: \(player.currentHP)/\(player.maxHP), Room: \(roomNumber)")
        
        // Generate new encounter
        let newEncounter: Encounter
        if roomNumber % 5 == 0 {
            // Every 5th room is a boss
            newEncounter = EncounterGenerator.generateBossEncounter(roomNumber: roomNumber)
            print("DEBUG prepareNextEncounter: Generated BOSS encounter for room \(roomNumber)")
        } else {
            newEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
            print("DEBUG prepareNextEncounter: Generated normal encounter for room \(roomNumber)")
        }
        
        currentEncounter = newEncounter
        
        print("DEBUG prepareNextEncounter: New encounter set with \(newEncounter.monsters.count) monster(s)")
        print("DEBUG prepareNextEncounter: New encounter room number: \(newEncounter.roomNumber)")
        if let firstMonster = newEncounter.monsters.first {
            print("DEBUG prepareNextEncounter: First monster: \(firstMonster.type.displayName)")
        }
        
        // Reset dice to show 1 pip for new encounter
        resetDiceToOne()
        
        // Re-enable buttons
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        // Update UI
        resultLabel.text = "Ready for the next challenge!"
        resultLabel.fontColor = .white
        updateUI()
        
        print("DEBUG prepareNextEncounter: UI updated, COMPLETE")
        print("DEBUG prepareNextEncounter: Verifying - roomNumber is now: \(roomNumber)")
    }
    
    private func startNewGame() {
        // Remove any existing dialogs
        childNode(withName: "initialsOverlay")?.removeFromParent()
        childNode(withName: "initialsPanel")?.removeFromParent()
        
        // Reset all game state
        player = Player()
        roomNumber = 1
        rollCount = 0
        hasRolled = false
        isRolling = false
        
        // Generate first encounter
        currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber)
        
        // Clear all slots and reset dice
        clearAllSlots()
        
        // Reset dice to show 1 pip for new game
        resetDiceToOne()
        
        // Reset all buttons
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        newGameButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        // Update UI
        resultLabel.text = "New game started! Click 'ROLL DICE' to begin!"
        resultLabel.fontColor = .white
        updateUI()
    }
    
    private func updateLeaderboard() {
        print("DEBUG updateLeaderboard: Called with \(highScores.count) high scores")
        print("DEBUG updateLeaderboard: leaderboardLabels.count = \(leaderboardLabels.count)")
        
        for (index, label) in leaderboardLabels.enumerated() {
            // Check if label is still in the scene
            if label.parent == nil {
                print("WARNING updateLeaderboard: Label [\(index)] has no parent! It was removed from scene.")
            }
            
            if index < highScores.count {
                let score = highScores[index]
                let rank = index + 1
                let text = String(format: "%2d. %@ %4dXP R%d", rank, score.initials, score.xp, score.roomNumber)
                label.text = text
                print("DEBUG updateLeaderboard: [\(index)] Setting: \(text)")
            } else {
                let text = String(format: "%2d. --- ----", index + 1)
                label.text = text
                print("DEBUG updateLeaderboard: [\(index)] Setting empty: \(text)")
            }
        }
        
        print("DEBUG updateLeaderboard: Leaderboard update complete")
    }
    
    private func handleGameEnd() {
        // Game ended (player died or quit)
        let finalXP = player.experience
        let finalRoom = roomNumber
        
        print("DEBUG handleGameEnd: Player died with \(finalXP) XP, Room \(finalRoom)")
        print("DEBUG handleGameEnd: Current high scores count: \(highScores.count)")
        
        // Check if this is a high score
        let qualifies = HighScoreManager.shared.isHighScore(xp: finalXP)
        print("DEBUG handleGameEnd: Qualifies for high score: \(qualifies)")
        
        if qualifies {
            print("DEBUG handleGameEnd: Showing initials entry dialog")
            showInitialsEntryDialog(xp: finalXP, roomNumber: finalRoom)
        } else {
            print("DEBUG handleGameEnd: Score too low, showing game over message")
            // Not a high score, just show game over message
            resultLabel.text = "💀 Game Over! 💀\nFinal Score: \(finalXP) XP, Room \(finalRoom)\nPress NEW GAME to try again!"
        }
    }
    
    private func showInitialsEntryDialog(xp: Int, roomNumber: Int) {
        // Disable buttons
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        newGameButton.alpha = 0.5
        
        // Calculate dimensions
        let panelWidth = min(size.width * 0.5, 400)
        let panelHeight = min(size.height * 0.4, 300)
        
        // Create semi-transparent overlay
        let overlay = SKShapeNode(rectOf: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.fillColor = SKColor.black
        overlay.alpha = 0.7
        overlay.zPosition = 200
        overlay.name = "initialsOverlay"
        addChild(overlay)
        
        // Create panel
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
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Arial Bold")
        titleLabel.text = "🏆 HIGH SCORE! 🏆"
        titleLabel.fontSize = 28
        titleLabel.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        titleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 50)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        // Score info
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Score: \(xp) XP • Room \(roomNumber)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 90)
        scoreLabel.verticalAlignmentMode = .center
        panel.addChild(scoreLabel)
        
        // Instructions
        let instructionLabel = SKLabelNode(fontNamed: "Arial")
        instructionLabel.text = "Enter your initials (3 letters):"
        instructionLabel.fontSize = 18
        instructionLabel.fontColor = .white
        instructionLabel.position = CGPoint(x: 0, y: 20)
        instructionLabel.verticalAlignmentMode = .center
        panel.addChild(instructionLabel)
        
        // Initials display
        let initialsLabel = SKLabelNode(fontNamed: "Courier Bold")
        initialsLabel.text = "___"
        initialsLabel.fontSize = 36
        initialsLabel.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        initialsLabel.position = CGPoint(x: 0, y: -25)
        initialsLabel.verticalAlignmentMode = .center
        initialsLabel.name = "initialsDisplay"
        panel.addChild(initialsLabel)
        
        // Submit instruction
        let submitLabel = SKLabelNode(fontNamed: "Arial")
        submitLabel.text = "Press RETURN to submit"
        submitLabel.fontSize = 16
        submitLabel.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        submitLabel.position = CGPoint(x: 0, y: -panelHeight / 2 + 40)
        submitLabel.verticalAlignmentMode = .center
        panel.addChild(submitLabel)
        
        // Animate panel in
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let appear = SKAction.group([scaleUp, fadeIn])
        panel.run(appear)
        
        // Store data for submission
        panel.userData = NSMutableDictionary()
        panel.userData?["xp"] = xp
        panel.userData?["roomNumber"] = roomNumber
        panel.userData?["initials"] = ""
    }
    
    private func dismissInitialsDialog(initials: String, xp: Int, roomNumber: Int) {
        print("DEBUG dismissInitialsDialog: Called with initials=\(initials), xp=\(xp), room=\(roomNumber)")
        
        // Save the high score
        print("DEBUG dismissInitialsDialog: Saving score...")
        HighScoreManager.shared.addScore(initials: initials, xp: xp, roomNumber: roomNumber)
        
        // Reload scores and update display
        print("DEBUG dismissInitialsDialog: Reloading scores...")
        highScores = HighScoreManager.shared.loadScores()
        print("DEBUG dismissInitialsDialog: Loaded \(highScores.count) scores")
        print("DEBUG dismissInitialsDialog: leaderboardLabels.count = \(leaderboardLabels.count)")
        
        print("DEBUG dismissInitialsDialog: Calling updateLeaderboard()...")
        updateLeaderboard()
        print("DEBUG dismissInitialsDialog: updateLeaderboard() complete")
        
        // Remove dialog
        childNode(withName: "initialsOverlay")?.removeFromParent()
        childNode(withName: "initialsPanel")?.removeFromParent()
        
        // Re-enable buttons
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        newGameButton.alpha = 1.0
        
        // Show completion message
        resultLabel.text = "💀 Game Over! 💀\nHigh score saved!\nPress NEW GAME to try again!"
        
        print("DEBUG dismissInitialsDialog: Complete")
    }

    
    private func handleDiceClick(_ dice: DiceNode) {
        guard hasRolled else {
            print("DEBUG: Dice click ignored - hasRolled is false")
            return
        }
        guard !isRolling else {
            print("DEBUG: Dice click ignored - still rolling")
            return
        }
        
        print("DEBUG: Dice clicked - \(dice.color.displayName) with value \(dice.getValue())")
        
        // Check if this dice is already slotted
        if let slotIndex = slottedDice.first(where: { $0.value == dice })?.key {
            // Remove from slot and move back
            print("DEBUG: Removing dice from slot \(slotIndex)")
            slottedDice.removeValue(forKey: slotIndex)
            if let diceIndex = self.dice.firstIndex(of: dice) {
                let moveBack = SKAction.move(to: originalDicePositions[diceIndex], duration: 0.3)
                dice.run(moveBack)
            }
        } else {
            // Find an empty slot
            for i in 0..<6 {
                if slottedDice[i] == nil {
                    print("DEBUG: Slotting dice into slot \(i)")
                    slottedDice[i] = dice
                    let moveToSlot = SKAction.move(to: diceSlots[i].position, duration: 0.3)
                    dice.run(moveToSlot)
                    break
                }
            }
        }
        
        print("DEBUG: Total slotted dice: \(slottedDice.count)")
        updateUI()
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNodes = nodes(at: location)
        
        // Check if run warning dialog is showing
        if childNode(withName: "runWarningPanel") != nil {
            for node in touchedNodes {
                if node.name == "confirmRunButton" || node.parent?.name == "confirmRunButton" {
                    runFromEncounter()
                    return
                }
                if node.name == "cancelRunButton" || node.parent?.name == "cancelRunButton" {
                    dismissRunWarningDialog()
                    return
                }
            }
            return // Prevent clicking through the dialog
        }
        
        // Check if reward panel is showing
        if childNode(withName: "rewardPanel") != nil {
            dismissRewardPanel()
            return
        }
        
        // Check if rest panel is showing (between monsters)
        if childNode(withName: "restPanel") != nil {
            if let handler = restCompletionHandler {
                handler()
            }
            return
        }
        
        for node in touchedNodes {
            // Check for new game button
            if node.name == "newGameButton" || node.parent?.name == "newGameButton" {
                startNewGame()
                return
            }
            
            // Check for roll button
            if node.name == "rollButton" || node.parent?.name == "rollButton" {
                rollAllDice()
                return
            }
            
            // Check for check button
            if node.name == "checkButton" || node.parent?.name == "checkButton" {
                print("DEBUG: Check button clicked! hasRolled: \(hasRolled), slottedDice.count: \(slottedDice.count)")
                if hasRolled && !slottedDice.isEmpty {
                    checkGoals()
                } else {
                    print("DEBUG: Check button disabled - hasRolled: \(hasRolled), isEmpty: \(slottedDice.isEmpty)")
                }
                return
            }
            
            // Check for run button
            if node.name == "runButton" || node.parent?.name == "runButton" {
                showRunWarningDialog()
                return
            }
            
            // Check for dice
            if let nodeName = node.name, nodeName.hasPrefix("dice_") {
                if let dice = node as? DiceNode {
                    handleDiceClick(dice)
                } else if let dice = node.parent as? DiceNode {
                    handleDiceClick(dice)
                }
                return
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        // Check if initials panel is showing
        if let panel = childNode(withName: "initialsPanel") as? SKShapeNode,
           let initialsLabel = panel.childNode(withName: "initialsDisplay") as? SKLabelNode,
           let userData = panel.userData {
            
            var currentInitials = userData["initials"] as? String ?? ""
            
            // Handle return key to submit
            if event.keyCode == 36 { // Return key
                if currentInitials.count == 3 {
                    let xp = userData["xp"] as? Int ?? 0
                    let room = userData["roomNumber"] as? Int ?? 0
                    dismissInitialsDialog(initials: currentInitials, xp: xp, roomNumber: room)
                }
                return
            }
            
            // Handle backspace/delete
            if event.keyCode == 51 { // Delete/Backspace
                if !currentInitials.isEmpty {
                    currentInitials.removeLast()
                    userData["initials"] = currentInitials
                    
                    // Update display
                    let display = currentInitials.padding(toLength: 3, withPad: "_", startingAt: 0)
                    initialsLabel.text = display.uppercased()
                }
                return
            }
            
            // Handle letter input (A-Z)
            if let characters = event.characters, currentInitials.count < 3 {
                let filtered = characters.uppercased().filter { $0.isLetter }
                if let char = filtered.first {
                    currentInitials.append(char)
                    userData["initials"] = currentInitials
                    
                    // Update display
                    let display = currentInitials.padding(toLength: 3, withPad: "_", startingAt: 0)
                    initialsLabel.text = display.uppercased()
                }
            }
            return
        }
        
        // Check if reward panel is showing
        if childNode(withName: "rewardPanel") != nil {
            dismissRewardPanel()
            return
        }
        
        // Check if run warning dialog is showing
        if childNode(withName: "runWarningPanel") != nil {
            if event.keyCode == 53 { // Escape key
                dismissRunWarningDialog()
            } else if event.keyCode == 36 { // Return key
                runFromEncounter()
            }
            return
        }
        
        // Check if rest panel is showing (between monsters)
        if childNode(withName: "restPanel") != nil {
            if let handler = restCompletionHandler {
                handler()
            }
            return
        }
        
        // Spacebar to roll dice
        if event.keyCode == 49 { // Spacebar
            rollAllDice()
        }
        
        // Return/Enter key to check
        if event.keyCode == 36 { // Return key
            if hasRolled && !slottedDice.isEmpty {
                checkGoals()
            }
        }
        
        // R key to show run dialog
        if event.keyCode == 15 { // R key
            if player.isAlive && currentEncounter?.isComplete == false {
                showRunWarningDialog()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
