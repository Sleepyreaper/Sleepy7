import SwiftUI

struct StatsDisplayView: View {
    let stats: GameStats

    var body: some View {
        VStack(spacing: 14) {
            Text("Stats")
                .font(.custom("Marker Felt", size: 24))
                .foregroundStyle(GameTheme.goldAccent)
                .shadow(color: GameTheme.goldAccent.opacity(0.5), radius: 4, x: 0, y: 0)

            VStack(spacing: 10) {
                StatRow(label: "Games Played", value: "\(stats.totalGamesPlayed)")
                StatRow(label: "Total Draws", value: "\(stats.totalCardDraws)")
                StatRow(label: "Avg Cards/Game", value: String(format: "%.1f", stats.averageCardsDrawn))
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(label: "Busts", value: "\(stats.totalBusts)", valueColor: Color(hex: "FF6B9D"))
                StatRow(label: "Bust Rate", value: String(format: "%.1f%%", stats.bustRate), valueColor: Color(hex: "FF6B9D"))
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(label: "Flip 7s", value: "\(stats.totalFlipSevens)", valueColor: Color(hex: "F1C40F"))
                StatRow(label: "Flip 7 Rate", value: String(format: "%.1f%%", stats.flipSevenRate), valueColor: Color(hex: "F1C40F"))
                StatRow(label: "Longest Streak", value: "\(stats.longestStreak)", valueColor: Color(hex: "2ECC71"))
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                StatRow(label: "Freezes", value: "\(stats.totalFreezes)", valueColor: Color(hex: "1ABC9C"))
                StatRow(label: "Second Chances", value: "\(stats.totalSecondChances)", valueColor: Color(hex: "2ECC71"))
                StatRow(label: "Total Points", value: "\(stats.totalPointsScored)", valueColor: GameTheme.goldAccent)
            }
            .padding(14)
            .background(Color.black.opacity(0.25))
            .cornerRadius(12)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(GameTheme.goldAccent.opacity(0.3), lineWidth: 1)
                }
        )
        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}

private struct StatRow: View {
    let label: String
    let value: String
    var valueColor: Color = GameTheme.goldAccent

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.85))
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(valueColor)
                .shadow(color: valueColor.opacity(0.3), radius: 2, x: 0, y: 0)
        }
    }
}

#Preview {
    StatsDisplayView(stats: GameStats(
        totalGamesPlayed: 5,
        totalCardDraws: 47,
        totalBusts: 8,
        totalFreezes: 3,
        totalFlipSevens: 2,
        totalSecondChances: 2,
        totalFlipThrees: 1,
        longestStreak: 2,
        currentStreak: 1,
        totalPointsScored: 450
    ))
    .background(Color(hex: "0F1216"))
}
