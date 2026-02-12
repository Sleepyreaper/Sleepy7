import Foundation
import SwiftUI

struct RoundHand {
    var numberCards: [Int] = []
    var modifiers: [ModifierType] = []
    var hasSecondChance = false
    var isBusted = false
    var isStayed = false
    var isFrozen = false
    var flippedSeven = false

    var uniqueNumberCount: Int {
        Set(numberCards).count
    }

    var isActive: Bool {
        !(isBusted || isStayed || isFrozen)
    }
}

final class GameEngine: ObservableObject {
    enum DrawSource {
        case initialDeal
        case hit
        case flipThree
    }

    @Published private(set) var players: [Player] = []
    @Published private(set) var roundHands: [UUID: RoundHand] = [:]
    @Published private(set) var roundNumber = 1
    @Published private(set) var dealerIndex = 0
    @Published var activePlayerIndex: Int? = nil
    @Published var lastAction = ""
    @Published var roundEndedReason: String? = nil
    @Published var lastDrawnCard: Card? = nil
    @Published var lastDrawSource: DrawSource = .initialDeal
    @Published var frozenPlayerName: String? = nil
    @Published var flippedSevenPlayerName: String? = nil
    @Published var winnerName: String? = nil
    @Published var aiThinkingDelay: Double = 1.0
    @Published var pendingFreezeAction = false
    @Published var stats: GameStats

    private var deck: [Card] = []
    private var discard: [Card] = []

    init() {
        self.stats = GameStats.load()
        startNewGame(playerCount: 3)
    }

    var isRoundOver: Bool {
        roundEndedReason != nil
    }

    var canAct: Bool {
        activePlayerIndex != nil && !isRoundOver
    }
    
    var isActivePlayerAI: Bool {
        guard let index = activePlayerIndex, players.indices.contains(index) else { return false }
        return players[index].isAI
    }

    var activePlayerName: String? {
        guard let index = activePlayerIndex, players.indices.contains(index) else { return nil }
        return players[index].name
    }

    var remainingDeckCount: Int {
        deck.count
    }

    func hand(for player: Player) -> RoundHand {
        roundHands[player.id] ?? RoundHand()
    }

    func roundScore(for player: Player) -> Int {
        let hand = hand(for: player)
        if hand.isBusted { return 0 }
        var score = hand.numberCards.reduce(0, +)
        if hand.modifiers.contains(.times2) {
            score *= 2
        }
        score += hand.modifiers.reduce(0) { $0 + $1.flatBonus }
        if hand.flippedSeven {
            score += 15
        }
        return score
    }

    func startNewGame(playerCount: Int, playerNames: [String]? = nil, aiPlayers: [Player]? = nil) {
        stats.recordGamePlayed()
        
        if let aiPlayers = aiPlayers {
            players = aiPlayers
        } else if let playerNames = playerNames, playerNames.count == playerCount {
            players = playerNames.map { Player(name: $0) }
        } else {
            players = (1...playerCount).map { Player(name: "Player \($0)") }
        }
        
        dealerIndex = 0
        roundNumber = 1
        winnerName = nil
        deck = Deck.shuffle(Deck.standardDeck())
        discard = []
        startRound()
    }

    func startNextRound() {
        // Add round scores to total scores
        for i in players.indices {
            let roundScore = roundScore(for: players[i])
            players[i].totalScore += roundScore
        }
        
        // Check for winner (200+ points)
        if let winner = players.first(where: { $0.totalScore >= 200 }) {
            winnerName = winner.name
            return
        }
        
        dealerIndex = (dealerIndex + 1) % players.count
        roundNumber += 1
        startRound()
    }

    func hit() {
        guard let index = activePlayerIndex else { return }
        lastDrawSource = .hit
        drawCard(for: players[index])
        advanceTurnIfNeeded()
    }

    func stay() {
        guard let index = activePlayerIndex else { return }
        var hand = roundHands[players[index].id] ?? RoundHand()
        hand.isStayed = true
        roundHands[players[index].id] = hand
        lastAction = "\(players[index].name) stayed."
        advanceTurnIfNeeded()
    }

    func startRound() {
        roundHands = Dictionary(uniqueKeysWithValues: players.map { ($0.id, RoundHand()) })
        activePlayerIndex = dealerIndex
        roundEndedReason = nil
        lastAction = "Draw a card to start!"
        lastDrawnCard = nil
        lastDrawSource = .initialDeal
        
        // Trigger AI turn if dealer is AI
        if players.indices.contains(dealerIndex) && players[dealerIndex].isAI {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.processAITurn()
            }
        }
    }

    private func dealInitialCards() {
        lastDrawSource = .initialDeal
        for player in players {
            drawCard(for: player)
        }
    }

    private func drawCard(for player: Player) {
        guard let card = drawFromDeck() else {
            lastAction = "Deck empty."
            return
        }
        lastDrawnCard = card
        stats.recordCardDraw()
        resolve(card: card, for: player)
    }

    private func resolve(card: Card, for player: Player) {
        switch card.kind {
        case .number(let value):
            applyNumber(value, to: player)
            discard.append(card)
        case .modifier(let modifier):
            applyModifier(modifier, to: player)
            discard.append(card)
        case .action(let action):
            discard.append(card)
            resolve(action: action, for: player)
        }
    }

    private func resolve(action: ActionType, for player: Player) {
        switch action {
        case .freeze:
            // For multiplayer, trigger target selection or AI auto-select
            if players.count > 1 {
                if player.isAI {
                    // AI automatically picks a random opponent to freeze
                    let opponents = players.filter { $0.id != player.id && !hand(for: $0).isFrozen }
                    if let target = opponents.randomElement() {
                        freeze(target)
                    }
                } else {
                    pendingFreezeAction = true
                    lastAction = "\(player.name) drew Freeze! Select a target."
                }
            } else {
                freeze(player)
            }
        case .flipThree:
            flipThree(player)
        case .secondChance:
            grantSecondChance(player)
        }
    }

    private func applyNumber(_ value: Int, to player: Player) {
        var hand = roundHands[player.id] ?? RoundHand()
        if Set(hand.numberCards).contains(value) {
            if hand.hasSecondChance {
                hand.hasSecondChance = false
                stats.recordSecondChance()
                lastAction = "\(player.name) used Second Chance on a duplicate \(value)."
            } else {
                hand.isBusted = true
                stats.recordBust()
                lastAction = "\(player.name) busted on duplicate \(value)."
            }
        } else {
            hand.numberCards.append(value)
            if hand.uniqueNumberCount == 7 {
                hand.flippedSeven = true
                flippedSevenPlayerName = player.name
                stats.recordFlipSeven()
                roundEndedReason = "\(player.name) flipped 7 and ends the round."
            }
        }
        roundHands[player.id] = hand
    }

    private func applyModifier(_ modifier: ModifierType, to player: Player) {
        var hand = roundHands[player.id] ?? RoundHand()
        hand.modifiers.append(modifier)
        roundHands[player.id] = hand
        lastAction = "\(player.name) drew \(modifier.rawValue)."
    }

    private func grantSecondChance(_ player: Player) {
        var hand = roundHands[player.id] ?? RoundHand()
        if hand.hasSecondChance {
            lastAction = "\(player.name) already has Second Chance."
        } else {
            hand.hasSecondChance = true
            lastAction = "\(player.name) gained Second Chance."
        }
        roundHands[player.id] = hand
    }

    private func freeze(_ player: Player) {
        var hand = roundHands[player.id] ?? RoundHand()
        hand.isFrozen = true
        hand.isStayed = true
        roundHands[player.id] = hand
        stats.recordFreeze()
        lastAction = "\(player.name) was frozen."
        frozenPlayerName = player.name
    }
    
    func freezePlayer(_ player: Player) {
        pendingFreezeAction = false
        freeze(player)
        advanceTurnIfNeeded()
    }

    private func flipThree(_ player: Player) {
        var pendingActions: [ActionType] = []
        lastDrawSource = .flipThree
        lastAction = "\(player.name) must flip three cards."
        stats.recordFlipThree()

        for _ in 0..<3 {
            if roundEndedReason != nil { break }
            if let card = drawFromDeck() {
                switch card.kind {
                case .action(let action):
                    pendingActions.append(action)
                    discard.append(card)
                case .number(let value):
                    discard.append(card)
                    applyNumber(value, to: player)
                case .modifier(let modifier):
                    discard.append(card)
                    applyModifier(modifier, to: player)
                }
            }

            let hand = roundHands[player.id] ?? RoundHand()
            if hand.isBusted || hand.flippedSeven { break }
        }

        let hand = roundHands[player.id] ?? RoundHand()
        if !hand.isBusted && !hand.flippedSeven {
            for action in pendingActions {
                resolve(action: action, for: player)
            }
        }
    }

    private func advanceTurnIfNeeded() {
        if let reason = roundEndedReason {
            finalizeRound(with: reason)
            return
        }

        if players.allSatisfy({ !hand(for: $0).isActive }) {
            finalizeRound(with: "All players are inactive. Round over.")
            return
        }

        guard let current = activePlayerIndex else { return }
        let total = players.count
        for offset in 1...total {
            let nextIndex = (current + offset) % total
            if hand(for: players[nextIndex]).isActive {
                activePlayerIndex = nextIndex
                
                // Trigger AI turn if this is an AI player
                if players[nextIndex].isAI {
                    DispatchQueue.main.asyncAfter(deadline: .now() + aiThinkingDelay) {
                        self.processAITurn()
                    }
                }
                return
            }
        }

        finalizeRound(with: "Round over.")
    }
    
    func processAITurn() {
        guard let index = activePlayerIndex, players.indices.contains(index) else { return }
        let player = players[index]
        guard player.isAI, let aiDifficulty = player.aiDifficulty else { return }
        
        let ai = AIPlayer(difficulty: aiDifficulty)
        let currentHand = hand(for: player)
        
        if ai.shouldHit(hand: currentHand, roundNumber: roundNumber) {
            hit()
        } else {
            stay()
        }
    }

    private func finalizeRound(with reason: String) {
        roundEndedReason = reason
        activePlayerIndex = nil
        for index in players.indices {
            let player = players[index]
            let earned = roundScore(for: player)
            players[index].totalScore += earned
        }
    }

    private func drawFromDeck() -> Card? {
        if deck.isEmpty {
            deck = discard.shuffled()
            discard.removeAll()
        }
        return deck.isEmpty ? nil : deck.removeFirst()
    }
}
