import SwiftUI

struct TurnBannerView: View {
    let banner: TurnBannerViewData
    let dismiss: () -> Void

    private var iconName: String {
        switch banner.kind {
        case .info:
            return "sparkles"
        case .success:
            return "checkmark.seal.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        }
    }

    private var iconColor: Color {
        switch banner.kind {
        case .info:
            return .blue
        case .success:
            return .green
        case .warning:
            return .yellow
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)

            Text(banner.text)
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
        .accessibilityLabel("Turn update. \(banner.text)")
    }
}