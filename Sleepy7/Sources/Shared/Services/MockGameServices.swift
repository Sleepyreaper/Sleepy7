import Foundation

final class MockGameSessionService: GameSessionProviding {
    private let snapshots: [GameSnapshot]

    init() {
        self.snapshots = [
            GameSnapshot(
                title: "Round 3",
                subtitle: "Ava's turn",
                players: [
                    GamePlayerSnapshot(id: UUID(), name: "Ava", totalScore: 44, roundScore: 12, isActive: true, isFrozen: false, isBusted: false, cardCount: 3, badgeText: "Dealer"),
                    GamePlayerSnapshot(id: UUID(), name: "Max", totalScore: 38, roundScore: 7, isActive: false, isFrozen: true, isBusted: false, cardCount: 2, badgeText: "Frozen"),
                    GamePlayerSnapshot(id: UUID(), name: "Bot Lux", totalScore: 51, roundScore: 0, isActive: false, isFrozen: false, isBusted: true, cardCount: 4, badgeText: "Bust")
                ],
                hand: [
                    GameCardSnapshot(id: UUID(), title: "7", subtitle: "Lucky draw", assetName: "Card7", accessibilityLabel: "Number card 7"),
                    GameCardSnapshot(id: UUID(), title: "+4", subtitle: "Modifier", assetName: nil, accessibilityLabel: "Modifier plus 4"),
                    GameCardSnapshot(id: UUID(), title: "Freeze", subtitle: "Action", assetName: "Freeze", accessibilityLabel: "Freeze action card")
                ],
                deckCount: 61,
                canHit: true,
                canStay: true,
                isGameOver: false
            )
        ]
    }

    func startNewMatch() async throws {}

    func hit() async throws {}

    func stay() async throws {}

    func stateStream() -> AsyncStream<GameSnapshot> {
        AsyncStream { continuation in
            for snapshot in snapshots {
                continuation.yield(snapshot)
            }
        }
    }
}

final class MockGameNetworkingService: GameNetworkingProviding {
    func turnUpdates() -> AsyncStream<TurnUpdate> {
        AsyncStream { continuation in
            continuation.yield(TurnUpdate(message: "Ava drew a unique 7", activePlayerName: "Ava"))
        }
    }
}

final class UserDefaultsOnboardingStore: OnboardingStoring {
    private let key = "sleepy7.hasSeenOnboarding"

    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}