import SwiftUI

// MARK: - Models used only for preview scaffolding
struct PlayerStats {
    var hp: Int = 100
    var maxHP: Int = 100
    var mana: Int = 3
    var maxMana: Int = 3
    var xp: Int = 0
    var level: Int = 1
}

struct EnemyInfo {
    var name: String = "Bat"
    var goalsCompleted: Int = 0
    var goalsRequired: Int = 1
    var goalDescription: String = "Blue and Purple match"
}

struct Die: Identifiable {
    let id = UUID()
    var color: Color
    var pips: Int
}

// MARK: - Main Game View
struct GameView: View {
    // In real app, inject observable view model(s)
    @State private var stats = PlayerStats()
    @State private var roomIndex: Int = 1
    @State private var rolls: Int = 0
    @State private var damageTaken: Int = 0
    @State private var enemy = EnemyInfo()

    @State private var dice: [Die] = [
        Die(color: .red, pips: 3),
        Die(color: .orange, pips: 2),
        Die(color: .yellow, pips: 4),
        Die(color: .green, pips: 4),
        Die(color: .blue, pips: 3),
        Die(color: .purple, pips: 4)
    ]

    var body: some View {
        ZStack {
            // Background
            Image("background_main")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header
                titleAndRoom

                HStack(alignment: .top, spacing: 16) {
                    leaderboardPanel
                    diceBoard
                    enemyPanel
                }

                bottomControls
            }
            .padding(16)
        }
        .navigationTitle("")
    }

    // MARK: Header
    private var header: some View {
        HStack(spacing: 24) {
            Label("HP: \(stats.hp)/\(stats.maxHP)", systemImage: "heart.fill")
                .foregroundStyle(.red)
                .font(.system(.title3, design: .rounded).weight(.bold))

            Label("Mana: \(stats.mana)/\(stats.maxMana)", systemImage: "drop.fill")
                .foregroundStyle(.blue)
                .font(.system(.title3, design: .rounded).weight(.bold))

            Label("XP: \(stats.xp) | Level: \(stats.level)", systemImage: "star.fill")
                .foregroundStyle(.yellow)
                .font(.system(.title3, design: .rounded).weight(.bold))

            Spacer()

            Button {
                // Hook up to new game action
                reset()
            } label: {
                Label("New Game", systemImage: "arrow.clockwise.circle.fill")
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThickMaterial, in: .capsule)
            }
        }
    }

    // MARK: Title + Room banner
    private var titleAndRoom: some View {
        VStack(spacing: 8) {
            Text("Dice Dungeon")
                .font(.system(size: 36, weight: .heavy, design: .serif))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .black, radius: 2, x: 1, y: 1)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background {
                     Image("header_bg")
                        .resizable()
                        .scaledToFill()
                }
                .padding(.top, 6)

            HStack {
                Text("Room \(roomIndex)")
                    .font(.title3.weight(.bold))
                Spacer()
                Text("Rolls: \(rolls) | Damage taken: \(damageTaken) HP")
                    .foregroundStyle(.green)
                    .font(.callout.weight(.semibold))
            }
            .padding(12)
            .background(.thinMaterial, in: .rect(cornerRadius: 12))
        }
    }

    // MARK: Left: Leaderboard
    private var leaderboardPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top Scores")
                .font(.title2.weight(.heavy))
                .padding(.bottom, 4)

            ForEach(1...10, id: \.self) { idx in
                HStack {
                    Text("\(idx). MPW")
                    Spacer()
                    Text("\(Int.random(in: 20...240))XP R\(Int.random(in: 1...12))")
                        .monospacedDigit()
                }
                .font(.callout)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(width: 260, minHeight: 420)
        .background {
            Image("panel_bg")
                .resizable()
                .ignoresSafeArea()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.3), lineWidth: 2))

    }

    // MARK: Center: Dice board
    private var diceBoard: some View {
        VStack(spacing: 16) {
            // 2x3 grid of dice
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                ForEach(dice) { die in
                    DieView(die: die)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(16)
            .background(boardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Stone slots row (placeholders)
            HStack(spacing: 12) {
                ForEach(0..<7) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.25))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.4), lineWidth: 2))
                        .frame(height: 56)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 420)
    }

    private var boardBackground: some View {
        Image("board_bg")
            .resizable()
            .scaledToFill()
            .overlay(.black.opacity(0.2))
    }

    // MARK: Right: Enemy panel
    private var enemyPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bat.fill")
                Text(enemy.name)
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(.orange)
                Spacer()
            }

            Text("Goals: \(enemy.goalsCompleted)/\(enemy.goalsRequired)")
                .font(.headline)

            Divider()

            Text("Goals to complete:")
                .font(.subheadline.weight(.semibold))
            Text("• \(enemy.goalDescription)")
                .foregroundStyle(.yellow)

            Spacer()

            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.2))
                .overlay(Image(systemName: "tortoise.fill").font(.system(size: 80)).opacity(0.4))
                .frame(height: 180)
        }
        .padding(12)
        .frame(width: 280, minHeight: 420)
        .background {
            Image("panel_bg")
                .resizable()
                .ignoresSafeArea()
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.3), lineWidth: 2))

    }

    // MARK: Bottom controls
    private var bottomControls: some View {
        VStack(spacing: 12) {
            Text("Click 'ROLL DICE' or press SPACE to roll all dice!")
                .font(.callout)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background {
                     Image("panel_bg")
                        .resizable()
                        .ignoresSafeArea()
                        .opacity(0.8)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.3), lineWidth: 1))

            HStack(spacing: 12) {
                abilityButton(title: "Nudge (1 MP)", color: .blue, systemImage: "hand.tap")
                abilityButton(title: "Flip (1 MP)", color: .purple, systemImage: "die.face.6")
                abilityButton(title: "Focus (1 MP)", color: .yellow, systemImage: "scope")
            }

            HStack(spacing: 16) {
                primaryButton(title: "Roll Dice", style: .secondary, systemImage: "die.face.5.fill") {
                    rolls += 1
                }
                primaryButton(title: "Check", style: .tinted, systemImage: "checkmark.seal.fill") {}
                primaryButton(title: "Run", style: .destructive, systemImage: "figure.run") {}
            }
        }
        .padding(.top, 8)
    }

    // MARK: Helpers
    private func reset() {
        stats = PlayerStats()
        roomIndex = 1
        rolls = 0
        damageTaken = 0
        enemy = EnemyInfo()
    }

    private func abilityButton(title: String, color: Color, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.15), in: .capsule)
            .overlay(Capsule().stroke(color.opacity(0.6)))
    }

    private enum PrimaryStyle { case secondary, tinted, destructive }

    private func primaryButton(title: String, style: PrimaryStyle, systemImage: String, action: @escaping () -> Void) -> some View {
        let bg: Color
        switch style {
        case .secondary: bg = .gray.opacity(0.25)
        case .tinted: bg = .blue.opacity(0.25)
        case .destructive: bg = .red.opacity(0.25)
        }
        return Button(action: action) {
            Label(title.uppercased(), systemImage: systemImage)
                .font(.headline.weight(.bold))
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .background {
            Image("button_bg_primary")
                .resizable()
                .colorMultiply(bg)
                .overlay(.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.5), lineWidth: 2))
    }
}

// MARK: - Die View
private struct DieView: View {
    let die: Die

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(die.color.gradient)
            RoundedRectangle(cornerRadius: 12)
                .stroke(.black.opacity(0.2), lineWidth: 2)

            // Very simple pip layout
            VStack(spacing: 8) {
                HStack { pipIf(positions: [.tl, .tr]) }
                HStack { pipIf(positions: [.c]) }
                HStack { pipIf(positions: [.bl, .br]) }
            }
            .padding(12)
        }
    }

    // Simple representation just to convey the look
    private func pipIf(positions: [PipPosition]) -> some View {
        HStack {
            if positions.contains(.tl) || positions.contains(.bl) { pip }
            Spacer()
            if positions.contains(.c) { pip }
            Spacer()
            if positions.contains(.tr) || positions.contains(.br) { pip }
        }
    }

    private var pip: some View {
        Circle().fill(Color.white.opacity(0.9)).frame(width: 10, height: 10)
    }

    private enum PipPosition { case tl, tr, c, bl, br }
}

#Preview {
    NavigationStack { GameView() }
}
