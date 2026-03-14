import Foundation

enum AIDifficulty: String, Codable, CaseIterable, Sendable {
    case easy
    case medium
    case hard
    case expert

    var name: String {
        switch self {
        case .easy: return "Easy Bot"
        case .medium: return "Medium Bot"
        case .hard: return "Hard Bot"
        case .expert: return "Expert Bot"
        }
    }
}

struct AIPlayer: Sendable {
    let difficulty: AIDifficulty

    /// Deterministic strategy for testability and fairness.
    func shouldHit(hand: RoundHand, roundNumber: Int) -> Bool {
        let total = hand.numberCards.reduce(0, +)
        let uniqueCount = hand.uniqueNumberCount

        switch difficulty {
        case .easy:
            return uniqueCount < 6 && total < 28
        case .medium:
            if uniqueCount >= 5 || total >= 30 { return false }
            return uniqueCount < 4 || total < 20
        case .hard:
            if uniqueCount >= 6 || total >= 35 { return false }
            let highCards = hand.numberCards.filter { $0 >= 7 }.count
            if highCards >= 3 && uniqueCount >= 4 { return false }
            return uniqueCount < 5 || total < 25
        case .expert:
            if uniqueCount >= 6 { return total < 40 }
            if uniqueCount >= 5 && total >= 30 { return false }
            if uniqueCount <= 3 { return true }
            if total >= 40 { return false }
            return uniqueCount < 6 && total < 35
        }
    }
}