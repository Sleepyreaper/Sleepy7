import SwiftUI

struct GameCardView: View {
    let card: TableCardViewData

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                LuxuryTheme.accentViolet(for: colorScheme).opacity(0.95),
                                LuxuryTheme.backgroundBottom(for: colorScheme).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)

                if let assetName = card.assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .accessibilityHidden(true)
                } else {
                    VStack(spacing: 4) {
                        Text(card.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        if let subtitle = card.subtitle {
                            Text(subtitle)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.84))
                        }
                    }
                    .padding(10)
                }
            }
            .frame(height: 128)

            Text(card.title)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(card.accessibilityLabel)
    }
}