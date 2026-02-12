import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Marker Felt", size: 24))
                .foregroundStyle(GameTheme.goldAccent)
                .shadow(color: GameTheme.goldAccent.opacity(0.6), radius: 4, x: 0, y: 0)
            if let subtitle {
                Text(subtitle)
                    .font(GameTheme.bodyFont(14))
                    .foregroundStyle(GameTheme.champagne.opacity(0.9))
            }
        }
    }
}
