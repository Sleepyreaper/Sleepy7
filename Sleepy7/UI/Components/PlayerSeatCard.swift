import SwiftUI

struct PlayerSeatCard: View {
    let player: PlayerSeatViewData
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(player.isActive ? LuxuryTheme.accentGold(for: colorScheme) : .white.opacity(0.16))
                    .frame(width: 44, height: 44)

                Text(String(player.name.prefix(1)).uppercased())
                    .font(.headline.weight(.bold))
                    .foregroundStyle(player.isActive ? .black : .white)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(player.name)
                        .font(.headline.weight(.semibold))

                    if let badgeText = player.badgeText {
                        Text(badgeText)
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 12) {
                    Label("\(player.totalScore)", systemImage: "crown.fill")
                    Label("\(player.roundScore)", systemImage: "sparkles")
                    Label("\(player.cardCount)", systemImage: "square.stack.3d.up.fill")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            }

            Spacer()

            statusPill
        }
        .padding(14)
        .background(.white.opacity(player.isActive ? 0.12 : 0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    player.isActive
                        ? LuxuryTheme.accentGold(for: colorScheme).opacity(0.55)
                        : .white.opacity(0.08),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var statusPill: some View {
        let title: String
        let color: Color

        if player.isBusted {
            title = "Bust"
            color = LuxuryTheme.danger(for: colorScheme)
        } else if player.isFrozen {
            title = "Frozen"
            color = .cyan
        } else if player.isActive {
            title = "Turn"
            color = LuxuryTheme.success(for: colorScheme)
        } else {
            title = "Waiting"
            color = .gray
        }

        Text(title)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var accessibilityText: String {
        "\(player.name). Total score \(player.totalScore). Round score \(player.roundScore). \(player.cardCount) cards. " +
        (player.isBusted ? "Busted." : player.isFrozen ? "Frozen." : player.isActive ? "Currently active." : "Waiting.")
    }
}