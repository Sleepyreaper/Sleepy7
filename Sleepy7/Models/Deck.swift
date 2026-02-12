import Foundation

struct Deck {
    static func standardDeck() -> [Card] {
        var cards: [Card] = []

        // Number cards: number of copies equals the card value, with one 0 card.
        cards.append(Card(.number(0)))
        for value in 1...12 {
            for _ in 0..<value {
                cards.append(Card(.number(value)))
            }
        }

        // Action cards: 3 each.
        for _ in 0..<3 {
            cards.append(Card(.action(.freeze)))
            cards.append(Card(.action(.flipThree)))
            cards.append(Card(.action(.secondChance)))
        }

        // Modifier cards: one each.
        cards.append(Card(.modifier(.times2)))
        cards.append(Card(.modifier(.plus2)))
        cards.append(Card(.modifier(.plus4)))
        cards.append(Card(.modifier(.plus6)))
        cards.append(Card(.modifier(.plus8)))
        cards.append(Card(.modifier(.plus10)))

        return cards
    }
    
    /// Fisher-Yates shuffle for proper randomization
    static func shuffle(_ cards: [Card]) -> [Card] {
        var shuffled = cards
        for i in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            if i != j {
                shuffled.swapAt(i, j)
            }
        }
        return shuffled
    }
}
