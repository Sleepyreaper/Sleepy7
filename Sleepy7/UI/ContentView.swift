import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var engine: GameEngine
    @State private var playerCount = 3
    @State private var gameMode: GameMode = .solo
    @State private var path: [Route] = []
    @State private var appear = false
    @State private var showSplash = true
    @State private var localPlayerName: String?
    @State private var authViewController: UIViewController?
    @State private var showAuthSheet = false
    
    enum GameMode {
        case solo
        case vsAI
        case localMultiplayer
        case onlineMultiplayer
    }

    var body: some View {
        ZStack {
            if showSplash {
                CardAnimationSplash {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showSplash = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeOut(duration: 0.6)) {
                            appear = true
                        }
                    }
                }
            } else {
                NavigationStack(path: $path) {
                    GeometryReader { geometry in
                        ZStack {
                            MainMenuBackgroundView()

                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 24) {
                                MainMenuHeroView()
                                    .opacity(appear ? 1 : 0)
                                    .offset(y: appear ? 0 : 12)

                                VStack(spacing: 10) {
                                    Text("Sleepy 7")
                                        .font(.custom("Marker Felt", size: 46))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [GameTheme.goldAccent, GameTheme.champagne],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: GameTheme.goldAccent.opacity(0.4), radius: 10, x: 0, y: 6)
                                    Text("Press-your-luck. Flip clean numbers. Avoid the bust.")
                                        .font(.custom("Avenir Next", size: 14))
                                        .foregroundStyle(GameTheme.champagne.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 12)
                                }
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 10)

                                VStack(spacing: 16) {
                                    // Game Mode Selector
                                    VStack(spacing: 12) {
                                        GameModeButton(
                                            title: "Solo Play",
                                            subtitle: "Play alone",
                                            isSelected: gameMode == .solo
                                        ) {
                                            gameMode = .solo
                                            playerCount = 1
                                        }
                                        
                                        GameModeButton(
                                            title: "vs AI",
                                            subtitle: "Play against 4 AI opponents",
                                            isSelected: gameMode == .vsAI
                                        ) {
                                            gameMode = .vsAI
                                            playerCount = 5
                                        }
                                        
                                        GameModeButton(
                                            title: "Local Multiplayer",
                                            subtitle: "Pass & play on this device",
                                            isSelected: gameMode == .localMultiplayer
                                        ) {
                                            gameMode = .localMultiplayer
                                            if playerCount < 2 { playerCount = 2 }
                                        }
                                        
                                        GameModeButton(
                                            title: "Online Multiplayer",
                                            subtitle: "Coming soon!",
                                            isSelected: gameMode == .onlineMultiplayer,
                                            isDisabled: true
                                        ) {
                                            gameMode = .onlineMultiplayer
                                        }
                                    }
                                    
                                    if gameMode == .localMultiplayer {
                                        Stepper("Players: \(playerCount)", value: $playerCount, in: 2...8)
                                            .font(.custom("Avenir Next", size: 16))
                                            .foregroundStyle(Color.white)
                                    }
                                }
                                .padding(18)
                                .background(Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                                .padding(.horizontal, 16)

                                Button {
                                    switch gameMode {
                                    case .solo:
                                        let playerNames = [localPlayerName ?? "Player 1"]
                                        engine.startNewGame(playerCount: 1, playerNames: playerNames)
                                        
                                    case .vsAI:
                                        var aiPlayers: [Player] = []
                                        // Human player first
                                        aiPlayers.append(Player(name: localPlayerName ?? "You", isAI: false))
                                        // 4 AI opponents with different difficulties
                                        aiPlayers.append(Player(name: "Easy Bot", isAI: true, aiDifficulty: .easy))
                                        aiPlayers.append(Player(name: "Medium Bot", isAI: true, aiDifficulty: .medium))
                                        aiPlayers.append(Player(name: "Hard Bot", isAI: true, aiDifficulty: .hard))
                                        aiPlayers.append(Player(name: "Expert Bot", isAI: true, aiDifficulty: .expert))
                                        engine.startNewGame(playerCount: 5, aiPlayers: aiPlayers)
                                        
                                    case .localMultiplayer:
                                        var playerNames: [String] = []
                                        if let gameCenterName = localPlayerName {
                                            playerNames.append(gameCenterName)
                                            playerNames.append(contentsOf: (2...playerCount).map { "Player \($0)" })
                                        } else {
                                            playerNames = (1...playerCount).map { "Player \($0)" }
                                        }
                                        engine.startNewGame(playerCount: playerCount, playerNames: playerNames)
                                        
                                    case .onlineMultiplayer:
                                        // Not implemented yet
                                        return
                                    }
                                    
                                    path.append(.game)
                                } label: {
                                    MainMenuPrimaryButton(title: "Start Game")
                                }
                                .padding(.horizontal, 16)

                                HStack(spacing: 12) {
                                    Button {
                                        path.append(.rules)
                                    } label: {
                                        MainMenuSecondaryButton(title: "Rules")
                                    }

                                    if engine.stats.totalGamesPlayed > 0 {
                                        Button {
                                            path.append(.stats)
                                        } label: {
                                            MainMenuSecondaryButton(title: "Stats")
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                        }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .onAppear {
                        GameCenterManager.shared.presentAuthViewController = { viewController in
                            authViewController = viewController
                            showAuthSheet = true
                        }
                        GameCenterManager.shared.authenticatePlayer { isAuthenticated in
                            DispatchQueue.main.async {
                                localPlayerName = GameCenterManager.shared.getLocalPlayerName()
                                if isAuthenticated {
                                    showAuthSheet = false
                                }
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showAuthSheet, onDismiss: {
                        localPlayerName = GameCenterManager.shared.getLocalPlayerName()
                    }) {
                        if let authViewController = authViewController {
                            AuthViewControllerWrapper(viewController: authViewController)
                                .ignoresSafeArea()
                        } else {
                            EmptyView()
                        }
                    }
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .game:
                            GameView()
                        case .rules:
                            RulesView()
                        case .stats:
                            StatsScreenView()
                        }
                    }
                }
            }
        }
    }
}

private struct AuthViewControllerWrapper: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private enum Route: Hashable {
    case game
    case rules
    case stats
}

struct GameModeButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Marker Felt", size: 18))
                        .foregroundStyle(isSelected ? GameTheme.goldAccent : GameTheme.champagne)
                    Text(subtitle)
                        .font(.custom("Avenir Next", size: 13))
                        .foregroundStyle(Color.white.opacity(0.6))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(GameTheme.goldAccent)
                        .font(.system(size: 20))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.black.opacity(0.4) : Color.black.opacity(0.2))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? GameTheme.goldAccent.opacity(0.5) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    }
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameEngine())
}
