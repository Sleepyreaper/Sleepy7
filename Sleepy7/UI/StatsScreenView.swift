import SwiftUI

struct StatsScreenView: View {
    @EnvironmentObject private var engine: GameEngine

    var body: some View {
        ZStack {
            VegasTableBackgroundView()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Text("Game Stats")
                            .font(.custom("Marker Felt", size: 40))
                            .foregroundStyle(GameTheme.goldAccent)
                            .shadow(color: GameTheme.goldAccent.opacity(0.6), radius: 8, x: 0, y: 0)
                        Text("Your performance metrics")
                            .font(GameTheme.bodyFont(14))
                            .foregroundStyle(GameTheme.champagne.opacity(0.9))
                    }
                    .padding(.top, 20)

                    StatsDisplayView(stats: engine.stats)

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StatsScreenView()
    }
    .environmentObject(GameEngine())
}
