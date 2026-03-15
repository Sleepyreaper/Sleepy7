import SwiftUI

struct PrivacyInfoView: View {
    @EnvironmentObject private var session: AppSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScreenContainer(
                title: "Privacy & Ads",
                subtitle: "The grown-up section: what gets shown, when consent matters, and why your premium purchase should not evaporate because someone owns a debugger."
            ) {
                SectionCard(title: "Ad Consent", systemImage: "hand.raised.fill") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Consent status: \(session.adConsentManager.consentStatus.rawValue.capitalized)")
                            .font(DesignSystem.Typography.bodyStrong)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)

                        Text("Tracking authorization: \(session.adConsentManager.trackingStatusDescription)")
                            .font(DesignSystem.Typography.body)
                            .foregroundStyle(DesignSystem.Colors.textSecondary)

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            CasinoButton("Allow Non-Personalized Ads", style: .secondary) {
                                session.adConsentManager.grantNonPersonalizedConsent()
                            }

                            CasinoButton("Allow Personalized Ads", style: .secondary) {
                                session.adConsentManager.grantPersonalizedConsent()
                            }
                        }

                        CasinoButton("Decline Ad Consent", style: .destructive) {
                            session.adConsentManager.denyConsent()
                        }
                    }
                }

                SectionCard(title: "Purchases", systemImage: "lock.shield.fill") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(DesignSystem.Copy.purchaseDisclosure)
                            .font(DesignSystem.Typography.body)
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Ad-Free active: \(session.iapManager.isAdFree ? "Yes" : "No")")
                            .font(DesignSystem.Typography.bodyStrong)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)

                        Text("Premium Themes active: \(session.iapManager.hasPremiumThemes ? "Yes" : "No")")
                            .font(DesignSystem.Typography.bodyStrong)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                    }
                }

                SectionCard(title: "Game Center", systemImage: "gamecontroller.fill") {
                    Text(DesignSystem.Copy.gameCenterDisclosure)
                        .font(DesignSystem.Typography.body)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(DesignSystem.Colors.accent)
                }
            }
        }
    }
}