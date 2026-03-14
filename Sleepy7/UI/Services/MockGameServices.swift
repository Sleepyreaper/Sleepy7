// … keep existing code above …

                    GameCardSnapshot(
                        id: UUID(),
                        title: "Freeze",
                        subtitle: "Action",
                        assetName: "Freeze",
                        accessibilityLabel: "Freeze action card"
                    )
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
            snapshots.forEach { snapshot in
                continuation.yield(snapshot)
            }
        }
    }
}

final class MockGameTurnUpdateService: GameTurnUpdateProviding {
    func turnUpdates() -> AsyncStream<TurnUpdate> {
        AsyncStream { continuation in
            continuation.yield(
                TurnUpdate(
                    message: "Ava drew a unique 7",
                    activePlayerName: "Ava",
                    kind: .success
                )
            )
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