import Foundation

enum AIDifficulty {
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

struct AIPlayer {
    let difficulty: AIDifficulty
    
    /// Decide whether AI should hit or stay based on current hand
    func shouldHit(hand: RoundHand, roundNumber: Int) -> Bool {
        let total = hand.numberCards.reduce(0, +)
        let uniqueCount = hand.uniqueNumberCount
        
        switch difficulty {
        case .easy:
            // Easy: Random decisions, slightly favors hitting
            return Bool.random() && uniqueCount < 6
            
        case .medium:
            // Medium: Basic strategy - stop at 5 unique cards or 30+ points
            if uniqueCount >= 5 { return false }
            if total >= 30 { return false }
            return uniqueCount < 4 || total < 20
            
        case .hard:
            // Hard: More calculated - considers risk of duplicates
            if uniqueCount >= 6 { return false }
            if total >= 35 { return false }
            
            // Calculate risk: if we have many high cards, risk of duplicate increases
            let highCards = hand.numberCards.filter { $0 >= 7 }.count
            if highCards >= 3 && uniqueCount >= 4 { return false }
            
            return uniqueCount < 5 || total < 25
            
        case .expert:
            // Expert: Optimal strategy
            // Aim for 6 unique cards (one away from flip 7)
            if uniqueCount >= 6 {
                // Only hit if we can potentially flip 7
                return uniqueCount == 6 && total < 40
            }
            
            // Calculate expected value based on remaining cards
            let availableNumbers = (0...12).filter { !hand.numberCards.contains($0) }
            if availableNumbers.isEmpty { return false }
            
            // Don't risk it if we have a good score and high unique count
            if uniqueCount >= 5 && total >= 30 { return false }
            
            // Be more aggressive early in the round
            if uniqueCount <= 3 { return true }
            
            // Conservative with high total
            if total >= 40 { return false }
            
            return uniqueCount < 6 && total < 35
        }
    }
}
