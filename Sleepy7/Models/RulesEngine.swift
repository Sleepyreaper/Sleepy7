import Foundation

struct RoundHand: Codable, Equatable, Sendable {
    var numberCards: [Int] = []
    var modifiers: [ModifierType] = []
    var hasSecondChance = false
    var isBusted = false
    var isStayed = false
    var isFrozen = false
    var flippedSeven = false

    var uniqueNumberCount: Int { Set(numberCards).count }
    var isActive: Bool { !(isBusted || isStayed || isFrozen) }
}

struct RulesEngine: Sendable {
    func apply(card: Card, to hand: inout RoundHand) -> RuleOutcome {
        switch card.kind {
        case .number(let value):
            if hand.numberCards.contains(value) {
                if hand.hasSecondChance {
                    hand.hasSecondChance = false
                    return .secondChanceUsed
                }
                hand.isBusted = true
                return .busted
            }

            hand.numberCards.append(value)

            if hand.uniqueNumberCount >= 7 {
                hand.flippedSeven = true
                hand.isStayed = true
                return .flippedSeven
            }

            return .numberAdded(value)

        case .modifier(let modifier):
            hand.modifiers.append(modifier)
            return .modifierApplied(modifier)

        case .action(let action):
            switch action {
            case .secondChance:
                hand.hasSecondChance = true
                return .secondChanceGranted
            case .freeze:
                return .freezeAvailable
            case .flipThree:
                return .flipThree
            }
        }
    }

    func score(for hand: RoundHand) -> Int {
        if hand.isBusted { return 0 }

        var total = hand.numberCards.reduce(0, +)

        if hand.modifiers.contains(.times2) {
            total *= 2
        }

        total += hand.modifiers.reduce(0) { $0 + $1.flatBonus }

        if hand.flippedSeven {
            total += 15
        }

        return total
    }
}

enum RuleOutcome: Equatable, Sendable, CustomStringConvertible {
    case numberAdded(Int)
    case modifierApplied(ModifierType)
    case secondChanceGranted
    case secondChanceUsed
    case freezeAvailable
    case flipThree
    case busted
    case flippedSeven

    var description: String {
        switch self {
        case .numberAdded(let value): return "numberAdded(\(value))"
        case .modifierApplied(let modifier): return "modifierApplied(\(modifier.rawValue))"
        case .secondChanceGranted: return "secondChanceGranted"
        case .secondChanceUsed: return "secondChanceUsed"
        case .freezeAvailable: return "freezeAvailable"
        case .flipThree: return "flipThree"
        case .busted: return "busted"
        case .flippedSeven: return "flippedSeven"
        }
    }
}