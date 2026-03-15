import SwiftUI

struct StatsScreenView: View {
    @EnvironmentObject private var engine: GameEngine
    @EnvironmentObject private var session: AppSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScreenContainer(
                title: "Stats",
                subtitle: "A cleaner performance dashboard with clearer hierarchy and enough polish to make counters feel expensive."
            ) {
                SectionCard(title: "Game Snapshot", systemImage: "chart.bar.xaxis") {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            StatPill(label: "Games Played", value: valueForStats("gamesPlayed"), accent: DesignSystem.Colors.accent)
                            StatPill(label: "Current Round", value: "\(engine.roundNumber)", accent: DesignSystem.Colors.info)
                        }

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            StatPill(label: "Players", value: "\(engine.players.count)", accent: DesignSystem.Colors.success)
                            StatPill(label: "Deck Left", value: "\(engine.remainingDeckCount)", accent: DesignSystem.Colors.warning)
                        }
                    }
                }

                SectionCard(title: "Performance Notes", systemImage: "sparkline") {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        insight("Game progress is tracked in the engine stats model.")
                        insight("This screen is ready for wins, busts, streaks, and flip-seven records.")
                        insight("If additional fields exist in GameStats, wire them into the helper below.")
                    }
                }

                SectionCard(title: "Monetization Status", systemImage: "dollarsign.circle.fill") {
                    if session.iapManager.isAdFree {
                        DisclosureNoticeCard(
                            title: "Ad-Free Upgrade Active",
                            bodyText: "Banner and rewarded ad placements are suppressed.",
                            systemImage: "nosign"
                        )
                    } else {
                        AdPlaceholderView(
                            title: "Optional Sponsored Placement",
                            subtitle: "Reserved for future banner ads on non-premium accounts after consent flow completion.",
                            systemImage: "rectangle.bottomthird.inset.filled",
                            showConsentBadge: true
                        )
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(DesignSystem.Colors.accent)
                }
            }
        }
    }

    private func insight(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DesignSystem.Colors.success)
                .padding(.top, 2)

            Text(text)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func valueForStats(_ key: String) -> String {
        let mirror = Mirror(reflecting: engine.stats)
        for child in mirror.children {
            guard let label = child.label else { continue }
            if label == key {
                return String(describing: child.value)
            }
        }
        return "—"
    }
}