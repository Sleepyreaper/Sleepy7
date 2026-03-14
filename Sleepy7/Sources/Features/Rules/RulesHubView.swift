import SwiftUI

struct RulesHubView: View {
    var body: some View {
        ZStack {
            LuxuryBackgroundView()

            ScrollView {
                GlassCard {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("How to Play Flip 7")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))

                        rule("1", "Hit for unique numbers", "Unique number cards add to your round and move you closer to Flip 7.")
                        rule("2", "Avoid duplicates", "If you draw a duplicate number already in your tableau, you usually bust the round.")
                        rule("3", "Use action cards wisely", "Freeze and Second Chance effects can swing momentum dramatically.")
                        rule("4", "Stay before disaster", "Bank your round score before greed sends it over the edge.")
                        rule("5", "Reach seven unique numbers", "That’s Flip 7—the signature moment and usually a huge scoring payoff.")
                    }
                }
                .padding(24)
                .frame(maxWidth: 880)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func rule(_ step: String, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(step)
                .font(.headline.weight(.bold))
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.10))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline.weight(.bold))
                Text(body)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}