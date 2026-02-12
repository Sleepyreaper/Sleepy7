import SwiftUI

struct GameView: View {
    @EnvironmentObject private var engine: GameEngine
    @Environment(\.dismiss) private var dismiss
    @State private var appear = false
    @State private var flipFaceUp = false
    @State private var animatedCard: Card? = nil
    @State private var duplicateCard: Card? = nil
    @State private var showDuplicate = false
    @State private var animateToHand = false
    @State private var isAnimating = false
    @State private var showBustOverlay = false
    @State private var showFreezeOverlay = false
    @State private var showFlipSevenOverlay = false
    @State private var showWinOverlay = false
    @State private var showFreezeTargetSelector = false
    @State private var pendingFreezeCard: Card? = nil
    @State private var lastBustCheck: [UUID: Bool] = [:]
    @State private var lastFrozenName: String? = nil
    @State private var lastFlipSevenName: String? = nil
    @State private var lastCardId: UUID? = nil

    private var activePlayerTotal: Int? {
        guard let index = engine.activePlayerIndex, engine.players.indices.contains(index) else { return nil }
        return engine.players[index].totalScore
    }

    var body: some View {
        ZStack {
            VegasTableBackgroundView()

            VStack(spacing: 0) {
                // Multiplayer scores at top
                if engine.players.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(engine.players) { player in
                                PlayerScoreChip(
                                    player: player,
                                    isActive: engine.activePlayerIndex == engine.players.firstIndex(where: { $0.id == player.id })
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(Color.black.opacity(0.3))
                    .frame(height: 90)
                } else if let totalScore = activePlayerTotal {
                    // Single player score (original)
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Total")
                                .font(.custom("Marker Felt", size: 13))
                                .foregroundStyle(Color.white.opacity(0.7))
                            Text("\(totalScore)")
                                .font(.custom("Marker Felt", size: 54))
                                .foregroundStyle(GameTheme.goldAccent)
                                .shadow(color: GameTheme.goldAccent.opacity(0.7), radius: 12, x: 0, y: 0)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                    }
                    .frame(height: 90)
                }

                ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if engine.players.count == 1 {
                        SectionHeaderView(
                            title: engine.roundEndedReason ?? (engine.activePlayerName.map { "Active: \($0)" } ?? ""),
                            subtitle: ""
                        )
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 8)
                    } else {
                        SectionHeaderView(
                            title: engine.roundEndedReason ?? "",
                            subtitle: ""
                        )
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 8)
                    }

                    FlipDeckView(
                        card: animatedCard, 
                        isFaceUp: flipFaceUp,
                        duplicateCard: duplicateCard,
                        showDuplicate: showDuplicate,
                        animateToHand: animateToHand
                    )
                        .frame(height: 220)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 12)

                    HStack(spacing: 12) {
                        Button(engine.isRoundOver ? "Next Round" : engine.lastAction.contains("start") ? "Draw" : "Hit") {
                            if engine.isRoundOver {
                                engine.startNextRound()
                            } else {
                                engine.hit()
                            }
                        }
                        .buttonStyle(PrimaryGameButtonStyle())
                        .disabled((!engine.canAct && !engine.isRoundOver) || isAnimating || engine.isActivePlayerAI)

                        Button("Stay") {
                            engine.stay()
                        }
                        .buttonStyle(SecondaryGameButtonStyle())
                        .disabled(!engine.canAct || isAnimating || engine.isActivePlayerAI)
                    }
                    
                    if engine.isActivePlayerAI {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(GameTheme.goldAccent)
                            Text("AI thinking...")
                                .font(GameTheme.bodyFont(14))
                                .foregroundStyle(GameTheme.champagne.opacity(0.8))
                        }
                        .padding(.vertical, 8)
                    }

                    if !engine.lastAction.isEmpty {
                        ActionStatusView(text: engine.lastAction)
                    }

                    Text("Deck: \(engine.remainingDeckCount) cards")
                        .font(GameTheme.bodyFont(13))
                        .foregroundStyle(Color.white.opacity(0.7))

                    ForEach(engine.players) { player in
                        PlayerHandView(
                            player: player,
                            hand: engine.hand(for: player),
                            roundScore: engine.roundScore(for: player)
                        )
                    }
                }
                .padding()
            }
            }

            if showBustOverlay {
                BustOverlayView {
                    showBustOverlay = false
                }
            }

            if showFreezeOverlay {
                FreezeOverlayView {
                    showFreezeOverlay = false
                }
            }

            if showFlipSevenOverlay {
                FlipSevenOverlayView {
                    showFlipSevenOverlay = false
                }
            }
            
            if showWinOverlay, let winnerName = engine.winnerName {
                let winner = engine.players.first(where: { $0.name == winnerName })
                WinOverlayView(
                    winnerName: winnerName,
                    winnerScore: winner?.totalScore ?? 0,
                    onDismiss: {
                        showWinOverlay = false
                    },
                    onNewGame: {
                        showWinOverlay = false
                        dismiss()
                    }
                )
            }
            
            if showFreezeTargetSelector {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    
                    FreezeTargetSelectorView(
                        players: engine.players.filter { player in
                            guard let activeIndex = engine.activePlayerIndex else { return false }
                            let isNotActivePlayer = player.id != engine.players[activeIndex].id
                            let isNotFrozen = !engine.hand(for: player).isFrozen
                            return isNotActivePlayer && isNotFrozen
                        },
                        onSelect: { targetPlayer in
                            showFreezeTargetSelector = false
                            engine.freezePlayer(targetPlayer)
                            pendingFreezeCard = nil
                        },
                        onCancel: {
                            showFreezeTargetSelector = false
                            engine.pendingFreezeAction = false
                            pendingFreezeCard = nil
                        }
                    )
                }
            }
        }
        .navigationTitle("Game")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appear = true
            }
            lastBustCheck = Dictionary(uniqueKeysWithValues: engine.players.map { ($0.id, false) })
        }
        .onChange(of: engine.lastDrawnCard?.id) { _ in
            guard let card = engine.lastDrawnCard else { return }
            if engine.lastDrawSource == .initialDeal { return }
            
            // Prevent duplicate animations for same card
            if lastCardId == card.id { return }
            lastCardId = card.id
            
            // Reset all animation states first
            animatedCard = nil
            flipFaceUp = false
            animateToHand = false
            showDuplicate = false
            duplicateCard = nil
            isAnimating = true
            
            // Small delay to ensure state is reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                // Check for duplicate number card
                var isDuplicate = false
                if let activeIndex = engine.activePlayerIndex {
                    let hand = engine.hand(for: engine.players[activeIndex])
                    if case .number(let value) = card.kind {
                        let count = hand.numberCards.filter({ $0 == value }).count
                        if count > 1 {
                            isDuplicate = true
                            duplicateCard = card
                        }
                    }
                }
                
                animatedCard = card
                
                // Check if it's FlipThree sequence (slower animation)
                let isFlipThree = engine.lastDrawSource == .flipThree
                let flipDuration = isFlipThree ? 1.0 : 0.6
                
                withAnimation(.easeInOut(duration: flipDuration)) {
                    flipFaceUp = true
                }
                
                // Show duplicate after flip
                if isDuplicate {
                    DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showDuplicate = true
                        }
                    }
                }
                
                // Animate card to hand after flip completes
                DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration + (isDuplicate ? 0.6 : 0.2)) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animateToHand = true
                    }
                    // Reset after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        animateToHand = false
                        showDuplicate = false
                        duplicateCard = nil
                        animatedCard = nil
                        flipFaceUp = false
                        lastCardId = nil
                        isAnimating = false
                    }
                }
            }
        }
        .onChange(of: engine.roundNumber) { _ in
            lastBustCheck = Dictionary(uniqueKeysWithValues: engine.players.map { ($0.id, false) })
        }
        .onChange(of: engine.lastAction) { _ in
            for player in engine.players {
                let currentHand = engine.hand(for: player)
                let wasBusted = lastBustCheck[player.id] ?? false
                if currentHand.isBusted && !wasBusted {
                    showBustOverlay = true
                    lastBustCheck[player.id] = true
                }
            }
        }
        .onChange(of: engine.frozenPlayerName) { _ in
            if let frozenName = engine.frozenPlayerName, frozenName != lastFrozenName {
                showFreezeOverlay = true
                lastFrozenName = frozenName
            }
        }
        .onChange(of: engine.flippedSevenPlayerName) { _ in
            if let sevenName = engine.flippedSevenPlayerName, sevenName != lastFlipSevenName {
                showFlipSevenOverlay = true
                lastFlipSevenName = sevenName
            }
        }
        .onChange(of: engine.winnerName) { _ in
            if engine.winnerName != nil {
                showWinOverlay = true
            }
        }
        .onChange(of: engine.pendingFreezeAction) { _ in
            if engine.pendingFreezeAction {
                showFreezeTargetSelector = true
            }
        }
    }
}

struct PlayerScoreChip: View {
    let player: Player
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(player.name)
                .font(.custom("Marker Felt", size: 14))
                .foregroundStyle(isActive ? GameTheme.goldAccent : GameTheme.champagne)
                .lineLimit(1)
            Text("\(player.totalScore)")
                .font(.custom("Marker Felt", size: 22))
                .fontWeight(.bold)
                .foregroundStyle(isActive ? GameTheme.goldAccent : Color.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Color.black.opacity(0.5) : Color.black.opacity(0.3))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? GameTheme.goldAccent.opacity(0.6) : Color.white.opacity(0.2), lineWidth: isActive ? 2 : 1)
                }
        )
        .shadow(color: isActive ? GameTheme.goldAccent.opacity(0.3) : .clear, radius: 8, x: 0, y: 0)
    }
}

struct FreezeTargetSelectorView: View {
    let players: [Player]
    let onSelect: (Player) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("❄️")
                        .font(.system(size: 48))
                    Text("Select Opponent to Freeze")
                        .font(.custom("Marker Felt", size: 26))
                        .foregroundStyle(GameTheme.goldAccent)
                    Text("Choose which player to freeze")
                        .font(GameTheme.bodyFont(14))
                        .foregroundStyle(GameTheme.champagne.opacity(0.8))
                }
                
                VStack(spacing: 12) {
                    ForEach(players) { player in
                        Button {
                            onSelect(player)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(player.name)
                                        .font(.custom("Marker Felt", size: 20))
                                        .foregroundStyle(GameTheme.champagne)
                                    Text("Total: \(player.totalScore)")
                                        .font(GameTheme.bodyFont(13))
                                        .foregroundStyle(Color.white.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "snowflake")
                                    .foregroundStyle(Color(hex: "1ABC9C"))
                                    .font(.system(size: 24))
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.black.opacity(0.4))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(GameTheme.goldAccent.opacity(0.3), lineWidth: 1)
                                    }
                            )
                        }
                    }
                }
                .frame(maxWidth: 320)
                
                Button("Cancel") {
                    onCancel()
                }
                .font(.custom("Marker Felt", size: 18))
                .foregroundStyle(GameTheme.champagne)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        }
                )
            }
            .padding(24)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameEngine())
}
