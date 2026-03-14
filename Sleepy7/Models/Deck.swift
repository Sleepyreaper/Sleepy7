import Foundation
import DequeModule

struct Deck: Sendable {
    private(set) var cards: Deque<Card>

    init(cards: Deque<Card>) {
        self.cards = cards
    }

    static func standard() -> Deck {
        var built: [Card] = []

        built.append(Card(.number(0)))
        for value in 1...12 {
            for _ in 0..<value {
                built.append(Card(.number(value)))
            }
        }

        for _ in 0..<3 {
            built.append(Card(.action(.freeze)))
            built.append(Card(.action(.flipThree)))
            built.append(Card(.action(.secondChance)))
        }

        built.append(Card(.modifier(.times2)))
        built.append(Card(.modifier(.plus2)))
        built.append(Card(.modifier(.plus4)))
        built.append(Card(.modifier(.plus6)))
        built.append(Card(.modifier(.plus8)))
        built.append(Card(.modifier(.plus10)))

        return Deck(cards: Deque(Self.shuffle(built)))
    }

    mutating func draw() -> Card? {
        cards.popFirst()
    }

    var count: Int { cards.count }

    static func shuffle(_ cards: [Card]) -> [Card] {
        var shuffled = cards
        guard shuffled.count > 1 else { return shuffled }

        for i in stride(from: shuffled.count - 1, through: 1, by: -1) {
            let j = Int.random(in: 0...i)
            if i != j {
                shuffled.swapAt(i, j)
            }
        }
        return shuffled
    }
}