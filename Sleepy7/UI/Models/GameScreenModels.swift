import Foundation

struct PlayerSeatViewData: Identifiable, Equatable {
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

struct TableCardViewData: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String?
    let assetName: String?
    let accessibilityLabel: String
}

struct TurnBannerViewData: Equatable {
    let id: UUID
    let text: String
    let kind: TurnUpdate.Kind
}

struct GameScreenState: Equatable {
    var title: String = "Sleepy7"
    var subtitle: String = "Your turn"
    var players: [PlayerSeatViewData] = []
    var currentHand: [TableCardViewData] = []
    var deckCount: Int = 0
    var isLoading: Bool = true
    var isHitEnabled: Bool = false
    var isStayEnabled: Bool = false
    var isAwaitingNetwork: Bool = false
    var banner: TurnBannerViewData?
    var errorMessage: String?
    var isGameOver: Bool = false
}