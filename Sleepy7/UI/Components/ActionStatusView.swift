import SwiftUI

struct ActionStatusView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(GameTheme.bodyFont(13))
            .foregroundStyle(GameTheme.champagne.opacity(0.95))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.4))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(GameTheme.goldAccent.opacity(0.25), lineWidth: 1)
                    }
            )
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}
