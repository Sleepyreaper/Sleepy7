import Foundation

struct Player: Identifiable, Equatable {
    let id: UUID
    var name: String
    var totalScore: Int
    var isAI: Bool
    var aiDifficulty: AIDifficulty?

    init(name: String, totalScore: Int = 0, isAI: Bool = false, aiDifficulty: AIDifficulty? = nil) {
        self.id = UUID()
        self.name = name
        self.totalScore = totalScore
        self.isAI = isAI
        self.aiDifficulty = aiDifficulty
    }
}
