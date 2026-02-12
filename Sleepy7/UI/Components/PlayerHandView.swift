import SwiftUI

struct PlayerHandView: View {
    let player: Player
    let hand: RoundHand
    let roundScore: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(player.name)
                    .font(GameTheme.titleFont(18))
                    .foregroundStyle(GameTheme.textPrimary)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(hand.numberCards, id: \.self) { value in
                        let imageName = imageNameForNumberCard(value)
                        CardMiniView(
                            label: String(value),
                            subtitle: "Number",
                            imageName: imageName
                        )
                    }
                    ForEach(hand.modifiers, id: \.rawValue) { modifier in
                        CardMiniView(label: modifier.rawValue, subtitle: "Mod", imageName: nil)
                    }
                }
            }

            HStack(spacing: 10) {
                Text("Round: \(roundScore)")
                    .font(GameTheme.bodyFont(13))
                    .foregroundStyle(GameTheme.textSecondary)
                StatusPill(text: hand.isBusted ? "Busted" : nil, color: .red)
                StatusPill(text: hand.isStayed ? "Stayed" : nil, color: .gray)
                StatusPill(text: hand.isFrozen ? "Frozen" : nil, color: .blue)
                if hand.hasSecondChance {
                    SecondChanceIconView()
                }
                StatusPill(text: hand.flippedSeven ? "Flip 7" : nil, color: .orange)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.35))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(GameTheme.goldAccent.opacity(0.25), lineWidth: 1)
                }
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
    }

    private func imageNameForNumberCard(_ value: Int) -> String? {
        switch value {
        case 0, 1, 2, 3, 7:
            return "Card\(value)"
        default:
            return nil
        }
    }
}

private struct StatusPill: View {
    let text: String?
    let color: Color

    var body: some View {
        if let text {
            Text(text)
                .font(GameTheme.bodyFont(11))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(color.opacity(0.2))
                .foregroundStyle(color)
                .clipShape(Capsule())
        }
    }
}

private struct SecondChanceIconView: View {
    var body: some View {
        Image("SecondChance")
            .resizable()
            .scaledToFit()
            .frame(height: 36)
    }
}
