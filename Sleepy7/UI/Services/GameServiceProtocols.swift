import Foundation

struct TurnUpdate: Sendable, Equatable {
    enum Kind: Sendable, Equatable {
        case info
        case success
        case warning
    }

    let id: UUID
    let message: String
    let activePlayerName: String
    let kind: Kind

    init(
        id: UUID = UUID(),
        message: String,
        activePlayerName: String,
        kind: Kind
    ) {
        self.id = id
        self.message = message
        self.activePlayerName = activePlayerName
        self.kind = kind
    }
}

struct GamePlayerSnapshot: Sendable, Equatable {
    let id: UUID
    let name: String
    let totalScore: Int
    let roundScore: Int
    let isActive: Bool
    let isFrozen: Bool
    let isBusted: Bool
    let cardCount: Int
    let badgeText: String?
}

struct GameCardSnapshot: Sendable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String?
    let assetName: String?
    let accessibilityLabel: String
}

struct GameSnapshot: Sendable, Equatable {
    let title: String
    let subtitle: String
    let players: [GamePlayerSnapshot]
    let hand: [GameCardSnapshot]
    let deckCount: Int
    let canHit: Bool
    let canStay: Bool
    let isGameOver: Bool
}

protocol GameSessionProviding: AnyObject {
    func startNewMatch() async throws
    func hit() async throws
    func stay() async throws
    func stateStream() -> AsyncStream<GameSnapshot>
}

protocol GameTurnUpdateProviding: AnyObject {
    /// UI assumes the underlying implementation has already validated or authenticated
    /// any remote event source before yielding a TurnUpdate.
    func turnUpdates() -> AsyncStream<TurnUpdate>
}

protocol OnboardingStoring: AnyObject {
    /// Non-sensitive only. This store must never be used for tokens, match payloads,
    /// keys, Game Center identifiers, or any other secret material.
    var hasSeenOnboarding: Bool { get set }
}