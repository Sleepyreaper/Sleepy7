import SwiftUI

struct LuxuryBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    LuxuryTheme.backgroundTop(for: colorScheme),
                    LuxuryTheme.backgroundBottom(for: colorScheme)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(LuxuryTheme.accentViolet(for: colorScheme).opacity(0.24))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: -120, y: -250)

            Circle()
                .fill(LuxuryTheme.accentGold(for: colorScheme).opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .offset(x: 150, y: -180)

            Circle()
                .fill(LuxuryTheme.accentEmerald(for: colorScheme).opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 85)
                .offset(x: 110, y: 280)
        }
    }
}