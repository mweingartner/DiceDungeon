//
//  GameScene.swift
//  DiceDungeon
//
//  Created by Michael Weingartner on 10/3/25.
//

import SpriteKit
import GameplayKit
import AppKit

private enum UITheme {
    static let backgroundTop = SKColor(red: 0.08, green: 0.09, blue: 0.13, alpha: 1.0)
    static let backgroundBottom = SKColor(red: 0.03, green: 0.04, blue: 0.08, alpha: 1.0)
    static let ambientGlowLeft = SKColor(red: 0.35, green: 0.18, blue: 0.45, alpha: 0.4)
    static let ambientGlowRight = SKColor(red: 0.12, green: 0.32, blue: 0.55, alpha: 0.35)
    static let panelFill = SKColor(red: 0.12, green: 0.13, blue: 0.18, alpha: 0.88)
    static let panelStroke = SKColor(red: 0.35, green: 0.38, blue: 0.5, alpha: 0.9)
    static let panelShadow = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.35)
    static let textPrimary = SKColor(white: 0.95, alpha: 1.0)
    static let textSecondary = SKColor(white: 0.78, alpha: 1.0)
    static let accentGold = SKColor(red: 0.98, green: 0.8, blue: 0.3, alpha: 1.0)
    static let accentRed = SKColor(red: 0.95, green: 0.35, blue: 0.35, alpha: 1.0)
    static let accentBlue = SKColor(red: 0.35, green: 0.6, blue: 0.95, alpha: 1.0)
    static let accentGreen = SKColor(red: 0.35, green: 0.8, blue: 0.45, alpha: 1.0)
    static let buttonShadow = SKColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 0.6)
    static let buttonStroke = SKColor(white: 0.92, alpha: 0.9)
    static let slotFill = SKColor(red: 0.18, green: 0.2, blue: 0.27, alpha: 0.6)
    static let slotStroke = SKColor(red: 0.4, green: 0.45, blue: 0.55, alpha: 0.9)
}

private enum UIFonts {
    static let title = "AvenirNextCondensed-DemiBold"
    static let header = "AvenirNext-DemiBold"
    static let body = "AvenirNext-Regular"
    static let button = "AvenirNext-Bold"
    static let mono = "Menlo-Bold"
}

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
        background.strokeColor = UITheme.buttonStroke
        background.lineWidth = 2
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
        pip.fillColor = UITheme.textPrimary
        pip.strokeColor = UITheme.textPrimary
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
    private var backgroundNode: SKSpriteNode?
    private var ambientGlows: [SKShapeNode] = []
    private var leftHudPanel: SKShapeNode?
    private var rightHudPanel: SKShapeNode?
    private var controlsPanel: SKShapeNode?
    private var resultPanel: SKShapeNode?
    private var maxGoalsInSingleCheck: Int = 1
    private var damageTakenThisEncounter: Int = 0
    private var encounterTimeRemaining: Int = 0
    private var encounterTimerActive: Bool = false
    private var timerLabel: SKLabelNode!
    private var timerTintNode: SKShapeNode?
    
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
        static let timerYOffset: CGFloat = 190      // Encounter timer
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
    
    private struct LayoutState {
        var buttonY: CGFloat = 0
        var skillButtonY: CGFloat = 0
        var resultLabelY: CGFloat = 0
        var controlsPanelSize: CGSize = .zero
        var controlsPanelCenter: CGPoint = .zero
        var slotSize: CGFloat = 0
        var slotSpacing: CGFloat = 0
        var slotY: CGFloat = 0
        var diceSpacing: CGFloat = 0
        var diceScale: CGFloat = 1
        var diceTopRowY: CGFloat = 0
        var diceBottomRowY: CGFloat = 0
        var characterImageSize: CGFloat = 0
        var characterImageY: CGFloat = 0
        var leftPanelSize: CGSize = .zero
        var leftPanelCenter: CGPoint = .zero
        var rightPanelSize: CGSize = .zero
        var rightPanelCenter: CGPoint = .zero
        var leaderboardLineHeight: CGFloat = 0
    }
    
    private var layoutState = LayoutState()
    
    override func didMove(to view: SKView) {
        backgroundColor = UITheme.backgroundBottom
        
        // Initialize game
        player = Player()
        currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber, playerLevel: player.level)
        rollCount = 0
        hasRolled = false
        gameEnded = false
        maxGoalsInSingleCheck = 1
        damageTakenThisEncounter = 0
        stopEncounterTimer()
        
        setupBackground()
        setupUI()
        setupDice()
        setupSlots()
        updateUI()
        startEncounterTimerIfNeeded()
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
            currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber, playerLevel: player.level)
            rollCount = 0
            hasRolled = false
            maxGoalsInSingleCheck = 1
            damageTakenThisEncounter = 0
            stopEncounterTimer()
        }
        
        setupBackground()
        setupUI()
        setupDice()
        setupSlots()
        updateUI()
        if encounterTimerActive {
            restartEncounterTimerTicker()
        }
    }
    
    private func setupBackground() {
        backgroundNode?.removeFromParent()
        ambientGlows.forEach { $0.removeFromParent() }
        ambientGlows.removeAll()
        
        if let texture = makeGradientTexture(size: size) {
            let node = SKSpriteNode(texture: texture)
            node.size = size
            node.position = CGPoint(x: size.width / 2, y: size.height / 2)
            node.zPosition = -100
            addChild(node)
            backgroundNode = node
        }
        
        let leftGlow = SKShapeNode(circleOfRadius: max(size.width, size.height) * 0.35)
        leftGlow.fillColor = UITheme.ambientGlowLeft
        leftGlow.strokeColor = .clear
        leftGlow.position = CGPoint(x: size.width * 0.2, y: size.height * 0.35)
        leftGlow.alpha = 0.6
        leftGlow.zPosition = -90
        addChild(leftGlow)
        ambientGlows.append(leftGlow)
        
        let rightGlow = SKShapeNode(circleOfRadius: max(size.width, size.height) * 0.3)
        rightGlow.fillColor = UITheme.ambientGlowRight
        rightGlow.strokeColor = .clear
        rightGlow.position = CGPoint(x: size.width * 0.85, y: size.height * 0.4)
        rightGlow.alpha = 0.5
        rightGlow.zPosition = -90
        addChild(rightGlow)
        ambientGlows.append(rightGlow)
    }
    
    private func makeGradientTexture(size: CGSize) -> SKTexture? {
        guard size.width > 0, size.height > 0 else { return nil }
        let image = NSImage(size: size)
        image.lockFocus()
        let gradient = NSGradient(colors: [UITheme.backgroundTop, UITheme.backgroundBottom])
        gradient?.draw(in: NSRect(origin: .zero, size: size), angle: -90)
        image.unlockFocus()
        return SKTexture(image: image)
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
        
        let controlsBottom = Layout.padding
        let buttonY = controlsBottom + Layout.buttonHeight / 2 + 8
        let skillButtonY = buttonY + Layout.buttonHeight / 2 + 14 + 22
        let resultY = skillButtonY + 22 + 24
        let controlsPanelHeight = max(180, resultY + 26 - controlsBottom)
        let controlsPanelWidth = size.width - Layout.padding * 2
        let controlsPanelCenter = CGPoint(x: size.width / 2, y: controlsBottom + controlsPanelHeight / 2)
        
        let leaderboardLineHeight = min(Layout.leaderboardLineHeight, smallFontSize + 2)
        let requiredLeftPanelHeight = max(200, 26 + 92 + 24 + leaderboardLineHeight * 10 + 16)
        
        var topHudHeight = min(260, max(180, size.height * 0.33))
        let minMiddleHeight: CGFloat = 200
        let maxTopHudHeight = max(140, size.height - controlsPanelHeight - minMiddleHeight - Layout.padding * 2)
        let requiredHudHeight = requiredLeftPanelHeight + 6
        topHudHeight = min(max(topHudHeight, requiredHudHeight), maxTopHudHeight)
        
        let middleBottom = controlsBottom + controlsPanelHeight + Layout.padding
        let middleTop = size.height - topHudHeight - Layout.padding
        let middleHeight = max(0, middleTop - middleBottom)
        
        let slotSize = min(90, sceneWidth / 10, max(60, middleHeight * 0.3))
        let slotSpacing = min(100, sceneWidth / 9)
        let slotY = middleBottom + slotSize / 2
        
        let diceSpacing = min(110, sceneWidth / 8)
        let diceGap: CGFloat = 24
        let availableForDice = max(0, middleTop - (slotY + slotSize / 2 + diceGap))
        let baseClusterHeight = 80 + 2 * 0.55 * diceSpacing
        let diceScale = max(0.45, min(1.0, availableForDice / baseClusterHeight))
        let rowOffset = 0.55 * diceSpacing * diceScale
        let clusterHeight = baseClusterHeight * diceScale
        let diceCenterY = slotY + slotSize / 2 + diceGap + clusterHeight / 2
        let diceTopRowY = diceCenterY + rowOffset
        let diceBottomRowY = diceCenterY - rowOffset
        
        let characterImageSize = min(Layout.characterImageSize, size.width * 0.2, max(90, middleHeight * 0.55))
        let characterImageY = middleBottom + middleHeight * 0.45
        
        let leftPanelWidth = min(300, size.width * 0.26)
        let leftPanelHeight = min(maxTopHudHeight, max(requiredLeftPanelHeight, topHudHeight - 6))
        let leftPanelCenter = CGPoint(x: Layout.padding + leftPanelWidth / 2,
                                      y: size.height - Layout.padding - leftPanelHeight / 2)
        let leftPanel = createPanel(size: CGSize(width: leftPanelWidth, height: leftPanelHeight),
                                    position: leftPanelCenter,
                                    cornerRadius: 18)
        leftPanel.alpha = 0.55
        leftHudPanel = leftPanel
        addChild(leftPanel)
        
        let rightPanelWidth = min(300, size.width * 0.26)
        let rightPanelHeight = min(maxTopHudHeight, max(leftPanelHeight, topHudHeight - 6))
        let rightPanelCenter = CGPoint(x: size.width - Layout.padding - rightPanelWidth / 2,
                                       y: size.height - Layout.padding - rightPanelHeight / 2)
        let rightPanel = createPanel(size: CGSize(width: rightPanelWidth, height: rightPanelHeight),
                                     position: rightPanelCenter,
                                     cornerRadius: 18)
        rightPanel.alpha = 0.55
        rightHudPanel = rightPanel
        addChild(rightPanel)
        
        let newControlsPanel = createPanel(size: CGSize(width: controlsPanelWidth, height: controlsPanelHeight),
                                           position: controlsPanelCenter,
                                           cornerRadius: 16)
        newControlsPanel.alpha = 0.6
        newControlsPanel.zPosition = -6
        newControlsPanel.name = "controlsPanel"
        controlsPanel?.removeFromParent()
        controlsPanel = newControlsPanel
        addChild(newControlsPanel)
        
        layoutState = LayoutState(
            buttonY: buttonY,
            skillButtonY: skillButtonY,
            resultLabelY: resultY,
            controlsPanelSize: CGSize(width: controlsPanelWidth, height: controlsPanelHeight),
            controlsPanelCenter: controlsPanelCenter,
            slotSize: slotSize,
            slotSpacing: slotSpacing,
            slotY: slotY,
            diceSpacing: diceSpacing,
            diceScale: diceScale,
            diceTopRowY: diceTopRowY,
            diceBottomRowY: diceBottomRowY,
            characterImageSize: characterImageSize,
            characterImageY: characterImageY,
            leftPanelSize: CGSize(width: leftPanelWidth, height: leftPanelHeight),
            leftPanelCenter: leftPanelCenter,
            rightPanelSize: CGSize(width: rightPanelWidth, height: rightPanelHeight),
            rightPanelCenter: rightPanelCenter,
            leaderboardLineHeight: leaderboardLineHeight
        )
        
        // Title
        titleLabel = SKLabelNode(fontNamed: UIFonts.title)
        titleLabel.text = "⚔️ Dice Dungeon ⚔️"
        titleLabel.fontSize = titleFontSize
        titleLabel.fontColor = UITheme.textPrimary
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - Layout.titleYOffset)
        addChild(titleLabel)
        
        // Room number
        roomNumberLabel = SKLabelNode(fontNamed: UIFonts.header)
        roomNumberLabel.fontSize = mediumFontSize
        roomNumberLabel.fontColor = UITheme.accentGold
        roomNumberLabel.position = CGPoint(x: size.width / 2, y: size.height - Layout.roomYOffset)
        addChild(roomNumberLabel)
        
        // Roll count (below room number)
        rollCountLabel = SKLabelNode(fontNamed: UIFonts.body)
        rollCountLabel.fontSize = normalFontSize
        rollCountLabel.fontColor = UITheme.textSecondary
        rollCountLabel.position = CGPoint(x: size.width / 2, y: size.height - Layout.rollCountYOffset)
        addChild(rollCountLabel)
        
        timerLabel = SKLabelNode(fontNamed: UIFonts.header)
        timerLabel.fontSize = normalFontSize
        timerLabel.fontColor = UITheme.textSecondary
        timerLabel.position = CGPoint(x: size.width / 2, y: size.height - Layout.timerYOffset)
        addChild(timerLabel)
        
        timerTintNode = SKShapeNode(rectOf: size)
        timerTintNode?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        timerTintNode?.fillColor = UITheme.accentRed
        timerTintNode?.strokeColor = .clear
        timerTintNode?.alpha = 0.0
        timerTintNode?.zPosition = 5
        if let timerTintNode {
            addChild(timerTintNode)
        }
        
        let leftPanelTop = layoutState.leftPanelCenter.y + layoutState.leftPanelSize.height / 2
        let leftPanelInsetX = layoutState.leftPanelCenter.x - layoutState.leftPanelSize.width / 2 + 18
        let statsStartY = leftPanelTop - 26
        
        // Player HP (left side)
        playerHPLabel = SKLabelNode(fontNamed: UIFonts.header)
        playerHPLabel.fontSize = largeFontSize
        playerHPLabel.fontColor = UITheme.accentRed
        playerHPLabel.position = CGPoint(x: leftPanelInsetX, y: statsStartY)
        playerHPLabel.horizontalAlignmentMode = .left
        addChild(playerHPLabel)
        
        // Player Mana (left side)
        playerManaLabel = SKLabelNode(fontNamed: UIFonts.header)
        playerManaLabel.fontSize = mediumFontSize
        playerManaLabel.fontColor = UITheme.accentBlue
        playerManaLabel.position = CGPoint(x: leftPanelInsetX, y: statsStartY - 28)
        playerManaLabel.horizontalAlignmentMode = .left
        addChild(playerManaLabel)
        
        // Player XP (left side)
        playerXPLabel = SKLabelNode(fontNamed: UIFonts.body)
        playerXPLabel.fontSize = normalFontSize
        playerXPLabel.fontColor = UITheme.textSecondary
        playerXPLabel.position = CGPoint(x: leftPanelInsetX, y: statsStartY - 56)
        playerXPLabel.horizontalAlignmentMode = .left
        addChild(playerXPLabel)
        
        // Leaderboard (left side, below player XP)
        leaderboardTitleLabel = SKLabelNode(fontNamed: UIFonts.header)
        leaderboardTitleLabel.text = "🏆 TOP SCORES 🏆"
        leaderboardTitleLabel.fontSize = normalFontSize
        leaderboardTitleLabel.fontColor = UITheme.accentGold
        let leaderboardTitleY = statsStartY - 92
        leaderboardTitleLabel.position = CGPoint(x: leftPanelInsetX, y: leaderboardTitleY)
        leaderboardTitleLabel.horizontalAlignmentMode = .left
        addChild(leaderboardTitleLabel)
        
        // Create 10 leaderboard entry labels
        let leaderboardStartY = leaderboardTitleY - 24
        let lineHeight = layoutState.leaderboardLineHeight
        
        leaderboardLabels.removeAll()
        for i in 0..<10 {
            let label = SKLabelNode(fontNamed: UIFonts.mono)
            label.fontSize = smallFontSize - 2
            label.fontColor = UITheme.accentGold
            label.position = CGPoint(x: leftPanelInsetX,
                                     y: leaderboardStartY - CGFloat(i) * lineHeight)
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
        playerImageNode.size = CGSize(width: layoutState.characterImageSize, height: layoutState.characterImageSize)
        playerImageNode.position = CGPoint(x: Layout.padding + layoutState.characterImageSize / 2,
                                           y: layoutState.characterImageY)
        addChild(playerImageNode)
        
        // Monster image placeholder
        if let encounter = currentEncounter, let monster = encounter.currentMonster {
            let monsterImageName = monster.type.rawValue
            let monsterImageTexture = SKTexture(imageNamed: monsterImageName)
            monsterImageNode = SKSpriteNode(texture: monsterImageTexture)
            monsterImageNode.size = CGSize(width: layoutState.characterImageSize, height: layoutState.characterImageSize)
            monsterImageNode.position = CGPoint(x: size.width - Layout.padding - layoutState.characterImageSize / 2,
                                                y: layoutState.characterImageY)
            addChild(monsterImageNode)
        }
        
        let rightPanelTop = layoutState.rightPanelCenter.y + layoutState.rightPanelSize.height / 2
        let rightPanelInsetX = layoutState.rightPanelCenter.x + layoutState.rightPanelSize.width / 2 - 18
        let rightPanelLeftInsetX = layoutState.rightPanelCenter.x - layoutState.rightPanelSize.width / 2 + 18
        
        // Monster info (right side)
        monsterInfoLabel = SKLabelNode(fontNamed: UIFonts.header)
        monsterInfoLabel.fontSize = largeFontSize
        monsterInfoLabel.fontColor = UITheme.accentGold
        monsterInfoLabel.position = CGPoint(x: rightPanelInsetX, y: rightPanelTop - 26)
        monsterInfoLabel.horizontalAlignmentMode = .right
        addChild(monsterInfoLabel)
        
        // Monster HP (right side)
        monsterHPLabel = SKLabelNode(fontNamed: UIFonts.body)
        monsterHPLabel.fontSize = normalFontSize
        monsterHPLabel.fontColor = UITheme.textSecondary
        monsterHPLabel.position = CGPoint(x: rightPanelInsetX, y: rightPanelTop - 46)
        monsterHPLabel.horizontalAlignmentMode = .right
        addChild(monsterHPLabel)
        
        // Goals label
        goalsLabel = SKLabelNode(fontNamed: UIFonts.body)
        goalsLabel.fontSize = smallFontSize
        goalsLabel.fontColor = UITheme.textSecondary
        goalsLabel.position = CGPoint(x: rightPanelLeftInsetX, y: monsterInfoLabel.position.y - 28.35)
        goalsLabel.numberOfLines = 0
        goalsLabel.preferredMaxLayoutWidth = max(200, layoutState.rightPanelSize.width - 30)
        goalsLabel.horizontalAlignmentMode = .left
        goalsLabel.verticalAlignmentMode = .top
        addChild(goalsLabel)
        
        // Main Buttons
        let buttonSpacingFor4 = Layout.buttonWidth + 24
        let totalWidth = buttonSpacingFor4 * 3
        let startX = (size.width - totalWidth) / 2
        
        // Roll button
        rollButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        rollButton.position = CGPoint(x: startX, y: layoutState.buttonY)
        rollButton.fillColor = UITheme.accentBlue
        rollButton.strokeColor = UITheme.buttonStroke
        rollButton.lineWidth = 2.5
        rollButton.name = "rollButton"
        addChild(rollButton)
        attachShadow(to: rollButton, size: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        
        rollButtonLabel = SKLabelNode(fontNamed: UIFonts.button)
        rollButtonLabel.text = "ROLL DICE"
        rollButtonLabel.fontSize = min(22, normalFontSize + 2)
        rollButtonLabel.fontColor = UITheme.textPrimary
        rollButtonLabel.verticalAlignmentMode = .center
        rollButton.addChild(rollButtonLabel)
        
        // Check button
        checkButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        checkButton.position = CGPoint(x: startX + buttonSpacingFor4, y: layoutState.buttonY)
        checkButton.fillColor = UITheme.accentGreen
        checkButton.strokeColor = UITheme.buttonStroke
        checkButton.lineWidth = 2.5
        checkButton.name = "checkButton"
        checkButton.alpha = 0.5
        addChild(checkButton)
        attachShadow(to: checkButton, size: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        
        checkButtonLabel = SKLabelNode(fontNamed: UIFonts.button)
        checkButtonLabel.text = "CHECK"
        checkButtonLabel.fontSize = min(22, normalFontSize + 2)
        checkButtonLabel.fontColor = UITheme.textPrimary
        checkButtonLabel.verticalAlignmentMode = .center
        checkButton.addChild(checkButtonLabel)
        
        // Run button
        runButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        runButton.position = CGPoint(x: startX + buttonSpacingFor4 * 2, y: layoutState.buttonY)
        runButton.fillColor = UITheme.accentGold
        runButton.strokeColor = UITheme.buttonStroke
        runButton.lineWidth = 2.5
        runButton.name = "runButton"
        addChild(runButton)
        attachShadow(to: runButton, size: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        
        runButtonLabel = SKLabelNode(fontNamed: UIFonts.button)
        runButtonLabel.text = "🏃 RUN"
        runButtonLabel.fontSize = min(22, normalFontSize + 2)
        runButtonLabel.fontColor = UITheme.textPrimary
        runButtonLabel.verticalAlignmentMode = .center
        runButton.addChild(runButtonLabel)
        
        // New Game button
        newGameButton = SKShapeNode(rectOf: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight), cornerRadius: 10)
        newGameButton.position = CGPoint(x: startX + buttonSpacingFor4 * 3, y: layoutState.buttonY)
        newGameButton.fillColor = UITheme.accentRed
        newGameButton.strokeColor = UITheme.buttonStroke
        newGameButton.lineWidth = 2.5
        newGameButton.name = "newGameButton"
        addChild(newGameButton)
        attachShadow(to: newGameButton,
                     size: CGSize(width: Layout.buttonWidth, height: Layout.buttonHeight),
                     cornerRadius: 10)
        
        newGameButtonLabel = SKLabelNode(fontNamed: UIFonts.button)
        newGameButtonLabel.text = "NEW GAME"
        newGameButtonLabel.fontSize = min(21, normalFontSize + 1)
        newGameButtonLabel.fontColor = UITheme.textPrimary
        newGameButtonLabel.verticalAlignmentMode = .center
        newGameButton.addChild(newGameButtonLabel)
        
        // --- SKILL BUTTONS ---
        let skillY = layoutState.skillButtonY
        let skillGap: CGFloat = 160
        
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
        
        // Result label
        resultLabel = SKLabelNode(fontNamed: UIFonts.body)
        resultLabel.fontSize = normalFontSize
        resultLabel.fontColor = UITheme.textPrimary
        resultLabel.position = CGPoint(x: size.width / 2, y: layoutState.resultLabelY)
        resultLabel.numberOfLines = 0
        resultLabel.preferredMaxLayoutWidth = max(200, layoutState.controlsPanelSize.width - Layout.padding * 2)
        addChild(resultLabel)
    }
    
    private func createSkillButton(text: String, icon: String, color: SKColor, position: CGPoint) -> SKShapeNode {
        let btn = SKShapeNode(rectOf: CGSize(width: 140, height: 44), cornerRadius: 10)
        btn.position = position
        btn.fillColor = color.withAlphaComponent(0.35)
        btn.strokeColor = color
        btn.lineWidth = 2.5
        attachShadow(to: btn, size: CGSize(width: 140, height: 44), cornerRadius: 10, offset: CGPoint(x: 0, y: -2))
        
        let label = SKLabelNode(fontNamed: UIFonts.button)
        label.text = "\(icon) \(text) (1 MP)"
        label.fontSize = 15
        label.fontColor = UITheme.textPrimary
        label.verticalAlignmentMode = .center
        label.name = "label"
        btn.addChild(label)
        
        return btn
    }
    
    private func createPanel(size: CGSize, position: CGPoint, cornerRadius: CGFloat) -> SKShapeNode {
        let panel = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        panel.position = position
        panel.fillColor = UITheme.panelFill
        panel.strokeColor = UITheme.panelStroke
        panel.lineWidth = 2.5
        panel.zPosition = -5
        attachShadow(to: panel,
                     size: size,
                     cornerRadius: cornerRadius,
                     offset: CGPoint(x: 0, y: -6),
                     color: UITheme.panelShadow,
                     alpha: 0.5)
        return panel
    }
    
    private func attachShadow(to node: SKShapeNode,
                              size: CGSize,
                              cornerRadius: CGFloat,
                              offset: CGPoint = CGPoint(x: 0, y: -4),
                              color: SKColor = UITheme.buttonShadow,
                              alpha: CGFloat = 0.7) {
        let shadow = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        shadow.fillColor = color
        shadow.strokeColor = .clear
        shadow.alpha = alpha
        shadow.position = offset
        shadow.zPosition = -1
        node.addChild(shadow)
    }
    
    private func setupDice() {
        // Scale dice based on scene size
        let diceSpacing = layoutState.diceSpacing
        let dicePerRow: CGFloat = 3
        
        let totalWidth = (dicePerRow - 1) * diceSpacing
        let startX = (size.width - totalWidth) / 2
        
        let topRowY = layoutState.diceTopRowY
        let bottomRowY = layoutState.diceBottomRowY
        
        // Top row
        for i in 0..<3 {
            let dice = DiceNode(color: diceColors[i])
            let position = CGPoint(x: startX + CGFloat(i) * diceSpacing, y: topRowY)
            dice.position = position
            dice.setScale(layoutState.diceScale)
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
            dice.setScale(layoutState.diceScale)
            dice.setValue(1)
            dice.name = "dice_\(i + 3)"
            self.dice.append(dice)
            self.originalDicePositions.append(position)
            addChild(dice)
        }
    }
    
    private func setupSlots() {
        let slotSize: CGFloat = layoutState.slotSize
        let slotSpacing = layoutState.slotSpacing
        let slotsPerRow: CGFloat = 6
        
        let totalWidth = (slotsPerRow - 1) * slotSpacing
        let startX = (size.width - totalWidth) / 2
        
        let slotY = layoutState.slotY
        
        for i in 0..<6 {
            let slot = SKShapeNode(rectOf: CGSize(width: slotSize, height: slotSize), cornerRadius: 10)
            slot.position = CGPoint(x: startX + CGFloat(i) * slotSpacing, y: slotY)
            slot.fillColor = UITheme.slotFill
            slot.strokeColor = UITheme.slotStroke
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
            rollCountLabel.fontColor = UITheme.accentGreen
        } else {
            rollCountLabel.fontColor = UITheme.accentRed
        }
        
        updateTimerLabel()
        
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
                stopEncounterTimer()
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
            resultLabel.text = "🎉 Room cleared! HP restored!"
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
            monsterImageNode.size = CGSize(width: layoutState.characterImageSize, height: layoutState.characterImageSize)
            monsterImageNode.position = CGPoint(x: size.width - Layout.padding - layoutState.characterImageSize / 2,
                                                y: layoutState.characterImageY)
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
            damageTakenThisEncounter += damage
            
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
        rollButton.fillColor = UITheme.panelStroke
        
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
                        self.rollButton.fillColor = UITheme.accentBlue
                        self.updateUI()
                    }
                }
            }
        }
        
        if totalDiceToRoll == 0 {
            isRolling = false
            rollButtonLabel.text = "ROLL AGAIN"
            rollButton.fillColor = UITheme.accentBlue
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
            maxGoalsInSingleCheck = max(maxGoalsInSingleCheck, goalsMet.count)
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
        stopEncounterTimer()
        
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
        let deathLabel = SKLabelNode(fontNamed: UIFonts.title)
        deathLabel.text = "💀 DEFEATED! 💀"
        deathLabel.fontSize = fontSize
        deathLabel.fontColor = UITheme.accentRed
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
        
        let restPanel = createPanel(size: CGSize(width: panelWidth, height: panelHeight),
                                    position: CGPoint(x: size.width / 2, y: size.height / 2),
                                    cornerRadius: 15)
        restPanel.zPosition = 50
        restPanel.fillColor = SKColor(red: 0.16, green: 0.28, blue: 0.22, alpha: 0.95)
        restPanel.strokeColor = UITheme.accentGreen
        restPanel.lineWidth = 2.5
        restPanel.alpha = 0
        restPanel.setScale(0.8)
        restPanel.name = "restPanel"
        addChild(restPanel)
        
        let restLabel = SKLabelNode(fontNamed: UIFonts.header)
        restLabel.text = "⚔️ One Down! ⚔️"
        restLabel.fontSize = min(32, panelWidth / 14)
        restLabel.fontColor = UITheme.accentGold
        restLabel.position = CGPoint(x: 0, y: panelHeight * 0.25)
        restLabel.verticalAlignmentMode = .center
        restPanel.addChild(restLabel)
        
        let nextLabel = SKLabelNode(fontNamed: UIFonts.body)
        nextLabel.text = "Next: \(nextMonster.type.emoji) \(nextMonster.type.displayName)"
        nextLabel.fontSize = min(20, panelWidth / 22)
        nextLabel.fontColor = UITheme.textPrimary
        nextLabel.position = CGPoint(x: 0, y: -panelHeight * 0.175)
        nextLabel.verticalAlignmentMode = .center
        restPanel.addChild(nextLabel)
        
        let continueLabel = SKLabelNode(fontNamed: UIFonts.body)
        continueLabel.text = "Click to continue..."
        continueLabel.fontSize = min(16, panelWidth / 28)
        continueLabel.fontColor = UITheme.textSecondary
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
        
        let deathLabel = SKLabelNode(fontNamed: UIFonts.title)
        deathLabel.text = "💀 DEFEATED! 💀"
        deathLabel.fontSize = fontSize
        deathLabel.fontColor = UITheme.accentRed
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
        let baseXP = encounter.totalXPValue
        let goalMultiplier = max(1, maxGoalsInSingleCheck)
        let noDamageMultiplier = (damageTakenThisEncounter == 0) ? 2 : 1
        let totalMultiplier = goalMultiplier * noDamageMultiplier
        let xpGained = baseXP * totalMultiplier
        let oldLevel = player.level
        
        player.gainExperience(xpGained)
        let leveledUp = player.level > oldLevel
        player.currentHP = player.maxHP
        
        let panelWidth = min(500, size.width * 0.7)
        let panelHeight = min(350, size.height * 0.5)
        
        let panel = createPanel(size: CGSize(width: panelWidth, height: panelHeight),
                                position: CGPoint(x: size.width / 2, y: size.height / 2),
                                cornerRadius: 20)
        panel.zPosition = 50
        panel.fillColor = SKColor(red: 0.16, green: 0.22, blue: 0.32, alpha: 0.95)
        panel.strokeColor = UITheme.accentGold
        panel.lineWidth = 3
        panel.alpha = 0
        panel.setScale(0.5)
        panel.name = "rewardPanel"
        addChild(panel)
        
        let titleLabel = SKLabelNode(fontNamed: UIFonts.header)
        titleLabel.text = "🏆 VICTORY! 🏆"
        titleLabel.fontSize = min(40, panelWidth / 12)
        titleLabel.fontColor = UITheme.accentGold
        titleLabel.position = CGPoint(x: 0, y: panelHeight * 0.34)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        let restLabel = SKLabelNode(fontNamed: UIFonts.header)
        restLabel.text = "💚 HP restored!"
        restLabel.fontSize = min(24, panelWidth / 20)
        restLabel.fontColor = UITheme.accentGreen
        restLabel.position = CGPoint(x: 0, y: panelHeight * 0.17)
        restLabel.verticalAlignmentMode = .center
        panel.addChild(restLabel)
        
        let xpLabel = SKLabelNode(fontNamed: UIFonts.header)
        if totalMultiplier > 1 {
            xpLabel.text = "⭐️ Gained \(xpGained) XP (Base \(baseXP) x\(totalMultiplier))"
        } else {
            xpLabel.text = "⭐️ Gained \(xpGained) XP!"
        }
        xpLabel.fontSize = min(22, panelWidth / 22)
        xpLabel.fontColor = UITheme.accentBlue
        xpLabel.position = CGPoint(x: 0, y: -panelHeight * 0.09)
        xpLabel.verticalAlignmentMode = .center
        panel.addChild(xpLabel)
        
        var bonusLines: [String] = []
        if goalMultiplier > 1 {
            bonusLines.append("Multi-goal x\(goalMultiplier)")
        }
        if noDamageMultiplier > 1 {
            bonusLines.append("Flawless x2")
        }
        
        if !bonusLines.isEmpty {
            let bonusLabel = SKLabelNode(fontNamed: UIFonts.body)
            bonusLabel.text = "Bonuses: " + bonusLines.joined(separator: " • ")
            bonusLabel.fontSize = min(18, panelWidth / 24)
            bonusLabel.fontColor = UITheme.textSecondary
            bonusLabel.position = CGPoint(x: 0, y: -panelHeight * 0.20)
            bonusLabel.verticalAlignmentMode = .center
            panel.addChild(bonusLabel)
        }
        
        if leveledUp {
            let levelUpLabel = SKLabelNode(fontNamed: UIFonts.header)
            levelUpLabel.text = "🎉 LEVEL UP! Now Level \(player.level)!"
            levelUpLabel.fontSize = min(26, panelWidth / 20)
            levelUpLabel.fontColor = UITheme.accentGold
            let levelUpY = bonusLines.isEmpty ? -panelHeight * 0.20 : -panelHeight * 0.28
            levelUpLabel.position = CGPoint(x: 0, y: levelUpY)
            levelUpLabel.verticalAlignmentMode = .center
            panel.addChild(levelUpLabel)
            
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.3),
                SKAction.scale(to: 1.0, duration: 0.3)
            ])
            levelUpLabel.run(SKAction.repeatForever(pulse))
        }
        
        let continueLabel = SKLabelNode(fontNamed: UIFonts.body)
        continueLabel.text = "Click to continue..."
        continueLabel.fontSize = min(18, panelWidth / 27)
        continueLabel.fontColor = UITheme.textSecondary
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
        
        // Ensure full heal
        player.currentHP = player.maxHP
        
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
        overlay.fillColor = UITheme.backgroundBottom
        overlay.alpha = 0.8
        overlay.zPosition = 100
        overlay.name = "runWarningOverlay"
        addChild(overlay)
        
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 20)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = UITheme.panelFill
        panel.strokeColor = UITheme.accentGold
        panel.lineWidth = 3
        panel.zPosition = 101
        panel.name = "runWarningPanel"
        panel.alpha = 0
        panel.setScale(0.5)
        addChild(panel)
        attachShadow(to: panel, size: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 20, offset: CGPoint(x: 0, y: -8), color: UITheme.panelShadow, alpha: 0.6)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        panel.run(SKAction.group([fadeIn, scaleUp]))
        
        let titleLabel = SKLabelNode(fontNamed: UIFonts.header)
        titleLabel.text = "⚠️ WARNING ⚠️"
        titleLabel.fontSize = min(32, panelWidth / 15)
        titleLabel.fontColor = UITheme.accentGold
        titleLabel.position = CGPoint(x: 0, y: panelHeight * 0.3)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        let messageLabel = SKLabelNode(fontNamed: UIFonts.body)
        messageLabel.text = "Running skips this encounter,\nbut you will NOT rest or heal!\n\nNext room HP: \(player.currentHP)"
        messageLabel.fontSize = min(20, panelWidth / 25)
        messageLabel.fontColor = UITheme.textPrimary
        messageLabel.position = CGPoint(x: 0, y: 0)
        messageLabel.verticalAlignmentMode = .center
        messageLabel.numberOfLines = 0
        panel.addChild(messageLabel)
        
        let buttonWidth: CGFloat = 140
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 80
        
        let confirmButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        confirmButton.position = CGPoint(x: -buttonSpacing, y: -panelHeight * 0.35)
        confirmButton.fillColor = UITheme.accentRed
        confirmButton.strokeColor = UITheme.buttonStroke
        confirmButton.name = "confirmRunButton"
        panel.addChild(confirmButton)
        attachShadow(to: confirmButton, size: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10, offset: CGPoint(x: 0, y: -3))
        
        let confirmLabel = SKLabelNode(fontNamed: UIFonts.button)
        confirmLabel.text = "RUN"
        confirmLabel.fontSize = 22
        confirmLabel.fontColor = UITheme.textPrimary
        confirmLabel.verticalAlignmentMode = .center
        confirmButton.addChild(confirmLabel)
        
        let cancelButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        cancelButton.position = CGPoint(x: buttonSpacing, y: -panelHeight * 0.35)
        cancelButton.fillColor = UITheme.accentGreen
        cancelButton.strokeColor = UITheme.buttonStroke
        cancelButton.name = "cancelRunButton"
        panel.addChild(cancelButton)
        attachShadow(to: cancelButton, size: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10, offset: CGPoint(x: 0, y: -3))
        
        let cancelLabel = SKLabelNode(fontNamed: UIFonts.button)
        cancelLabel.text = "CANCEL"
        cancelLabel.fontSize = 22
        cancelLabel.fontColor = UITheme.textPrimary
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
        maxGoalsInSingleCheck = 1
        damageTakenThisEncounter = 0
        stopEncounterTimer()
        clearAllSlots()
        
        roomNumber += 1
        if roomNumber % 5 == 0 {
            currentEncounter = EncounterGenerator.generateBossEncounter(roomNumber: roomNumber, playerLevel: player.level)
        } else {
            currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber, playerLevel: player.level)
        }
        resetDiceToOne()
        
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        resultLabel.text = "⚠️ You ran away! No rest or healing."
        resultLabel.fontColor = UITheme.accentGold
        updateUI()
        startEncounterTimerIfNeeded()
        
        let flash = SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.3), SKAction.fadeAlpha(to: 1.0, duration: 0.3)])
        resultLabel.run(SKAction.repeat(flash, count: 2))
    }
    
    private func prepareNextEncounter() {
        rollCount = 0
        hasRolled = false
        currentSkillMode = .none
        maxGoalsInSingleCheck = 1
        damageTakenThisEncounter = 0
        stopEncounterTimer()
        roomNumber += 1
        
        player.currentHP = player.maxHP
        
        if roomNumber % 5 == 0 {
            currentEncounter = EncounterGenerator.generateBossEncounter(roomNumber: roomNumber, playerLevel: player.level)
        } else {
            currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber, playerLevel: player.level)
        }
        
        resetDiceToOne()
        
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        resultLabel.text = "Ready for the next challenge!"
        resultLabel.fontColor = UITheme.textPrimary
        updateUI()
        startEncounterTimerIfNeeded()
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
        maxGoalsInSingleCheck = 1
        damageTakenThisEncounter = 0
        stopEncounterTimer()
        
        currentEncounter = EncounterGenerator.generateEncounter(roomNumber: roomNumber, playerLevel: player.level)
        clearAllSlots()
        resetDiceToOne()
        
        rollButton.alpha = 1.0
        checkButton.alpha = 0.5
        runButton.alpha = 1.0
        newGameButton.alpha = 1.0
        rollButtonLabel.text = "ROLL DICE"
        
        resultLabel.text = "New game started! Click 'ROLL DICE' to begin!"
        resultLabel.fontColor = UITheme.textPrimary
        updateUI()
        startEncounterTimerIfNeeded()
    }
    
    private func startEncounterTimerIfNeeded() {
        guard player.level >= 11 else {
            encounterTimerActive = false
            encounterTimeRemaining = 0
            updateTimerLabel()
            stopEncounterTimer()
            return
        }
        
        let reduction = max(0, player.level - 11) * 5
        encounterTimeRemaining = max(90, 180 - reduction)
        encounterTimerActive = true
        updateTimerLabel()
        restartEncounterTimerTicker()
    }
    
    private func restartEncounterTimerTicker() {
        guard encounterTimerActive else { return }
        removeAction(forKey: "encounterTimerTick")
        let tick = SKAction.run { [weak self] in
            self?.tickEncounterTimer()
        }
        let sequence = SKAction.sequence([SKAction.wait(forDuration: 1.0), tick])
        run(SKAction.repeatForever(sequence), withKey: "encounterTimerTick")
    }
    
    private func stopEncounterTimer() {
        encounterTimerActive = false
        removeAction(forKey: "encounterTimerTick")
        timerLabel?.removeAction(forKey: "timerPulse")
        timerLabel?.setScale(1.0)
        timerLabel?.text = ""
        timerTintNode?.removeAction(forKey: "timerTintPulse")
        timerTintNode?.alpha = 0.0
    }
    
    private func tickEncounterTimer() {
        guard encounterTimerActive else { return }
        guard currentEncounter?.isComplete == false else { return }
        guard player.isAlive else { return }
        
        encounterTimeRemaining = max(0, encounterTimeRemaining - 1)
        updateTimerLabel()
        
        if encounterTimeRemaining == 0 {
            handleTimerExpired()
        }
    }
    
    private func updateTimerLabel() {
        guard let timerLabel = timerLabel else { return }
        guard encounterTimerActive, player.level >= 11 else {
            timerLabel.text = ""
            timerTintNode?.removeAction(forKey: "timerTintPulse")
            timerTintNode?.alpha = 0.0
            return
        }
        
        let minutes = encounterTimeRemaining / 60
        let seconds = encounterTimeRemaining % 60
        timerLabel.text = String(format: "⏳ %d:%02d", minutes, seconds)
        timerLabel.fontColor = encounterTimeRemaining <= 30 ? UITheme.accentRed : UITheme.textSecondary
        
        if encounterTimeRemaining <= 30 {
            if timerLabel.action(forKey: "timerPulse") == nil {
                let pulse = SKAction.sequence([
                    SKAction.scale(to: 1.12, duration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2),
                    SKAction.wait(forDuration: 0.6)
                ])
                timerLabel.run(SKAction.repeatForever(pulse), withKey: "timerPulse")
            }
            if timerTintNode?.action(forKey: "timerTintPulse") == nil {
                let tintPulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.18, duration: 0.25),
                    SKAction.fadeAlpha(to: 0.05, duration: 0.25),
                    SKAction.wait(forDuration: 0.5)
                ])
                timerTintNode?.run(SKAction.repeatForever(tintPulse), withKey: "timerTintPulse")
            }
        } else {
            timerLabel.removeAction(forKey: "timerPulse")
            timerLabel.setScale(1.0)
            timerTintNode?.removeAction(forKey: "timerTintPulse")
            timerTintNode?.alpha = 0.0
        }
    }
    
    private func handleTimerExpired() {
        guard !gameEnded else { return }
        gameEnded = true
        encounterTimerActive = false
        
        rollButton.alpha = 0.5
        checkButton.alpha = 0.5
        runButton.alpha = 0.5
        skillNudgeButton.alpha = 0.3
        skillFlipButton.alpha = 0.3
        skillFocusButton.alpha = 0.3
        
        resultLabel.text = "⏳ Time's up! You were overwhelmed."
        resultLabel.fontColor = UITheme.accentRed
        player.currentHP = 0
        
        let wait = SKAction.wait(forDuration: 1.0)
        let showDialog = SKAction.run { [weak self] in
            self?.handleGameEnd()
        }
        run(SKAction.sequence([wait, showDialog]))
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
        overlay.fillColor = UITheme.backgroundBottom
        overlay.alpha = 0.8
        overlay.zPosition = 200
        overlay.name = "initialsOverlay"
        addChild(overlay)
        
        let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 20)
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.fillColor = UITheme.panelFill
        panel.strokeColor = UITheme.accentGold
        panel.lineWidth = 3
        panel.zPosition = 201
        panel.name = "initialsPanel"
        panel.setScale(0.5)
        panel.alpha = 0
        addChild(panel)
        attachShadow(to: panel, size: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 20, offset: CGPoint(x: 0, y: -8), color: UITheme.panelShadow, alpha: 0.6)
        
        let titleLabel = SKLabelNode(fontNamed: UIFonts.header)
        titleLabel.text = "🏆 HIGH SCORE! 🏆"
        titleLabel.fontSize = 28
        titleLabel.fontColor = UITheme.accentGold
        titleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 50)
        titleLabel.verticalAlignmentMode = .center
        panel.addChild(titleLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: UIFonts.body)
        scoreLabel.text = "Score: \(xp) XP • Room \(roomNumber)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = UITheme.textPrimary
        scoreLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 90)
        panel.addChild(scoreLabel)
        
        let instructionLabel = SKLabelNode(fontNamed: UIFonts.body)
        instructionLabel.text = "Enter your initials (3 letters):"
        instructionLabel.fontSize = 18
        instructionLabel.fontColor = UITheme.textSecondary
        instructionLabel.position = CGPoint(x: 0, y: 20)
        panel.addChild(instructionLabel)
        
        let initialsLabel = SKLabelNode(fontNamed: UIFonts.mono)
        initialsLabel.text = "___"
        initialsLabel.fontSize = 36
        initialsLabel.fontColor = UITheme.accentGold
        initialsLabel.position = CGPoint(x: 0, y: -25)
        initialsLabel.name = "initialsDisplay"
        panel.addChild(initialsLabel)
        
        let submitLabel = SKLabelNode(fontNamed: UIFonts.body)
        submitLabel.text = "Press RETURN to submit"
        submitLabel.fontSize = 16
        submitLabel.fontColor = UITheme.textSecondary
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
