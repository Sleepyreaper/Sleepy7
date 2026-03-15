import SwiftUI

struct AdPlaceholderView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var showConsentBadge: Bool = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.accent.opacity(0.18))
                    .frame(width: 40, height: 40)

                Image(systemName: systemImage)
                    .foregroundStyle(DesignSystem.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.bodyStrong)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)

                Text(subtitle)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if showConsentBadge {
                    Text("Consent-aware placement")
                        .font(DesignSystem.Typography.captionStrong)
                        .foregroundStyle(DesignSystem.Colors.info)
                }
            }

            Spacer()

            Text("Ad")
                .font(DesignSystem.Typography.captionStrong)
                .foregroundStyle(DesignSystem.Colors.accent)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(
                    Capsule(style: .continuous)
                        .fill(DesignSystem.Colors.accent.opacity(0.12))
                )
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(maxWidth: .infinity, minHeight: DesignSystem.Layout.bottomAdHeight)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                .fill(DesignSystem.Colors.adPlaceholderBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                .stroke(DesignSystem.Colors.adPlaceholderBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

struct RewardedSecondChancePrompt: View {
    let isLoading: Bool
    let consentReady: Bool
    let onWatchAd: () -> Void
    let onDismiss: () -> Void
    let onReviewPrivacy: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Second Chance")
                    .font(DesignSystem.Typography.title2)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)

                Text("Busts happen. Opt in to a rewarded experience for one extra recovery attempt.")
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            AdPlaceholderView(
                title: "Rewarded Video",
                subtitle: consentReady
                    ? "Available after consent and platform permissions are complete."
                    : "Unavailable until ad consent and permissions are completed.",
                systemImage: "play.rectangle.fill",
                showConsentBadge: true
            )

            if !consentReady {
                DisclosureNoticeCard(
                    title: "Ad permissions required",
                    bodyText: DesignSystem.Copy.adConsentDisclosure,
                    systemImage: "hand.raised.fill"
                )
            }

            HStack(spacing: DesignSystem.Spacing.sm) {
                CasinoButton("Not Now", style: .secondary, action: onDismiss)

                CasinoButton(
                    isLoading ? "Loading…" : "Watch for Second Chance",
                    systemImage: "sparkles.tv",
                    style: .primary,
                    isEnabled: consentReady && !isLoading,
                    action: onWatchAd
                )
            }

            if let onReviewPrivacy {
                Button("Review Privacy & Ads") {
                    onReviewPrivacy()
                }
                .font(DesignSystem.Typography.footnote)
                .foregroundStyle(DesignSystem.Colors.accent)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .casinoCardStyle()
        .accessibilityElement(children: .contain)
    }
}