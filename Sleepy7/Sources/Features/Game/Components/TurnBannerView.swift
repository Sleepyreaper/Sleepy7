import SwiftUI

struct TurnBannerView: View {
    let text: String
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(.yellow)
            Text(text)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            Spacer()
            Button(action: dismiss) {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .padding(6)
                    .background(.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Dismiss update banner")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Turn update. \(text)")
    }
}