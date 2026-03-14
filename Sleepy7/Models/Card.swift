import Foundation

enum ActionType: String, CaseIterable, Codable, Sendable {
    case freeze = "Freeze"
    case flipThree = "Flip Three"
    case secondChance = "Second Chance"
}

enum ModifierType: String, CaseIterable, Codable, Sendable {
    case times2 = "x2"
    case plus2 = "+2"
    case plus4 = "+4"
    case plus6 = "+6"
    case plus8 = "+8"
    case plus10 = "+10"

    var isMultiplier: Bool { self == .times2 }

    var flatBonus: Int {
        switch self {
        case .times2: return 0
        case .plus2: return 2
        case .plus4: return 4
        case .plus6: return 6
        case .plus8: return 8
        case .plus10: return 10
        }
    }
}

struct Card: Identifiable, Equatable, Codable, Sendable {
    enum Kind: Equatable, Codable, Sendable {
        case number(Int)
        case action(ActionType)
        case modifier(ModifierType)
    }

    let id: UUID
    let kind: Kind

    init(id: UUID = UUID(), _ kind: Kind) {
        self.id = id
        self.kind = kind
    }
}