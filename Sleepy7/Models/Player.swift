import Foundation

enum PlayerKind: Codable, Equatable, Sendable {
    case local
    case ai(level: AIDifficulty)
    case gameCenter(id: String)
}

struct Player: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var totalScore: Int
    var kind: PlayerKind

    init(
        id: UUID = UUID(),
        name: String,
        totalScore: Int = 0,
        kind: PlayerKind = .local
    ) {
        self.id = id
        self.name = name
        self.totalScore = totalScore
        self.kind = kind
    }

    var isAI: Bool {
        if case .ai = kind { return true }
        return false
    }
}