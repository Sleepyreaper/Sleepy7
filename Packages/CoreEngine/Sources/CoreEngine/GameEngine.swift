import Foundation

public struct RoundHand: Sendable, Equatable {
    public var numberCards: [Int] = []
    public var hasSecondChance = false
    public var isBusted = false
    public var isStayed = false

    public var uniqueNumberCount: Int { Set(numberCards).count }
    public var total: Int { numberCards.reduce(0, +) }

    public init() {}
}

public enum PlayerAction: Sendable, Equatable {
    case hit
    case stay
    case startRound
}

public actor GameEngine {
    public struct Snapshot: Sendable, Equatable {
        public let playerHands: [Int: RoundHand]
        public let activePlayerIndex: Int
        public let roundNumber: Int
        public let isRoundOver: Bool
        public let winnerIndex: Int?
    }

    private let playerCount: Int
    private var roundNumber: Int = 1
    private var activePlayerIndex: Int = 0
    private var hands: [Int: RoundHand] = [:]
    private var deck: [Int] = []
    private var seededRngState: UInt64
    private var winnerIndex: Int?

    public init(playerCount: Int = 3, playerNames: [String]? = nil, seed: UInt64 = 42) {
        self.playerCount = max(2, playerCount)
        self.seededRngState = seed
        for p in 0..<self.playerCount {
            hands[p] = RoundHand()
        }
        resetDeck()
    }

    public func snapshot() -> Snapshot {
        Snapshot(
            playerHands: hands,
            activePlayerIndex: activePlayerIndex,
            roundNumber: roundNumber,
            isRoundOver: winnerIndex != nil || hands.values.allSatisfy { $0.isStayed || $0.isBusted },
            winnerIndex: winnerIndex
        )
    }

    public func startNewRound() async {
        roundNumber += 1
        activePlayerIndex = 0
        winnerIndex = nil
        hands = Dictionary(uniqueKeysWithValues: (0..<playerCount).map { ($0, RoundHand()) })
        resetDeck()
    }

    public func handle(action: PlayerAction) async {
        switch action {
        case .startRound:
            await startNewRound()
        case .stay:
            guard var hand = hands[activePlayerIndex], !hand.isBusted else { return }
            hand.isStayed = true
            hands[activePlayerIndex] = hand
            advanceTurn()
            computeWinnerIfDone()
        case .hit:
            guard var hand = hands[activePlayerIndex], !hand.isStayed, !hand.isBusted else { return }
            let card = drawDeterministicCard()
            if hand.numberCards.contains(card) {
                if hand.hasSecondChance {
                    hand.hasSecondChance = false
                } else {
                    hand.isBusted = true
                }
            } else {
                hand.numberCards.append(card)
                if hand.uniqueNumberCount >= 7 {
                    winnerIndex = activePlayerIndex
                }
            }
            hands[activePlayerIndex] = hand
            if winnerIndex == nil {
                advanceTurn()
                computeWinnerIfDone()
            }
        }
    }

    private func computeWinnerIfDone() {
        let done = hands.values.allSatisfy { $0.isStayed || $0.isBusted }
        guard done else { return }
        let scored = hands.map { ($0.key, $0.value.isBusted ? 0 : $0.value.total) }
        winnerIndex = scored.max(by: { $0.1 < $1.1 })?.0
    }

    private func advanceTurn() {
        for _ in 0..<playerCount {
            activePlayerIndex = (activePlayerIndex + 1) % playerCount
            if let hand = hands[activePlayerIndex], !hand.isStayed, !hand.isBusted { return }
        }
    }

    private func resetDeck() {
        deck = Array(0...12) + Array(0...12)
        deterministicShuffle(&deck)
    }

    private func drawDeterministicCard() -> Int {
        if deck.isEmpty { resetDeck() }
        return deck.removeFirst()
    }

    private func deterministicShuffle(_ array: inout [Int]) {
        guard array.count > 1 else { return }
        for i in stride(from: array.count - 1, through: 1, by: -1) {
            let j = Int(nextRandom() % UInt64(i + 1))
            array.swapAt(i, j)
        }
    }

    private func nextRandom() -> UInt64 {
        seededRngState = 2862933555777941757 &* seededRngState &+ 3037000493
        return seededRngState
    }
}