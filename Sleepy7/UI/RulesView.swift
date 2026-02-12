import SwiftUI

struct RulesView: View {
    var body: some View {
        ZStack {
            VegasTableBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Rules")
                        .font(.custom("Marker Felt", size: 36))
                        .foregroundStyle(GameTheme.goldAccent)
                        .shadow(color: GameTheme.goldAccent.opacity(0.6), radius: 6, x: 0, y: 0)
                        .padding(.bottom, 8)

                    RuleCard(title: "Objective") {
                        Text("Score the most points by revealing unique number cards. Draw a duplicate and you bust for the round.")
                            .font(GameTheme.bodyFont(15))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }

                    RuleCard(title: "Flip 7 Bonus") {
                        Text("Reveal 7 unique number cards to end the round and score +15 points.")
                            .font(GameTheme.bodyFont(15))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }

                    RuleCard(title: "Actions") {
                        Text("Freeze: target banks points and is out.\nFlip Three: target draws 3 in a row (stop on bust or Flip 7).\nSecond Chance: discard it to ignore one duplicate number.")
                            .font(GameTheme.bodyFont(15))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }

                    RuleCard(title: "Modifiers") {
                        Text("x2 doubles your number total. +2/+4/+6/+8/+10 add after multiplying.")
                            .font(GameTheme.bodyFont(15))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }

                    RuleCard(title: "Round End") {
                        Text("All players stayed or busted, or one player flips 7.")
                            .font(GameTheme.bodyFont(15))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                }
                .padding()
            }
        }
    }
}

private struct RuleCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("Marker Felt", size: 20))
                            .foregroundStyle(GameTheme.champagne)
                            .shadow(color: GameTheme.goldAccent.opacity(0.4), radius: 4, x: 0, y: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.35))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(GameTheme.goldAccent.opacity(0.2), lineWidth: 1)
                }
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    RulesView()
}
