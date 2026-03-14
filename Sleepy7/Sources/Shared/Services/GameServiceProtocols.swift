import Foundation

struct TurnUpdate: Sendable, Equatable {
    let message: String
    let activePlayerName: String
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

protocol GameNetworkingProviding: AnyObject {
    func turnUpdates() -> AsyncStream<TurnUpdate>
}

protocol OnboardingStoring: AnyObject {
    var hasSeenOnboarding: Bool { get set }
}