import Foundation

struct GameStats: Codable {
    private static let userDefaultsKey = "sleepy7_game_stats"
    
    var totalGamesPlayed: Int = 0
    var totalCardDraws: Int = 0
    var totalBusts: Int = 0
    var totalFreezes: Int = 0
    var totalFlipSevens: Int = 0
    var totalSecondChances: Int = 0
    var totalFlipThrees: Int = 0
    var longestStreak: Int = 0
    var currentStreak: Int = 0
    var totalPointsScored: Int = 0
    var averageCardsDrawn: Double {
        totalGamesPlayed > 0 ? Double(totalCardDraws) / Double(totalGamesPlayed) : 0
    }
    
    var bustRate: Double {
        totalCardDraws > 0 ? Double(totalBusts) / Double(totalCardDraws) * 100 : 0
    }
    
    var flipSevenRate: Double {
        totalGamesPlayed > 0 ? Double(totalFlipSevens) / Double(totalGamesPlayed) * 100 : 0
    }

    mutating func recordGamePlayed() {
        totalGamesPlayed += 1
        save()
    }

    mutating func recordCardDraw() {
        totalCardDraws += 1
        save()
    }

    mutating func recordBust() {
        totalBusts += 1
        currentStreak = 0
        save()
    }

    mutating func recordFreeze() {
        totalFreezes += 1
        save()
    }

    mutating func recordFlipSeven() {
        totalFlipSevens += 1
        currentStreak += 1
        longestStreak = max(longestStreak, currentStreak)
        save()
    }

    mutating func recordSecondChance() {
        totalSecondChances += 1
        save()
    }

    mutating func recordFlipThree() {
        totalFlipThrees += 1
        save()
    }

    mutating func recordPoints(_ points: Int) {
        totalPointsScored += points
        save()
    }
    
    mutating func save() {
        do {
            let encoded = try JSONEncoder().encode(self)
            UserDefaults.standard.set(encoded, forKey: GameStats.userDefaultsKey)
        } catch {
            print("Failed to save game stats: \(error)")
        }
    }
    
    static func load() -> GameStats {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return GameStats()
        }
        do {
            return try JSONDecoder().decode(GameStats.self, from: data)
        } catch {
            print("Failed to load game stats: \(error)")
            return GameStats()
        }
    }
}
