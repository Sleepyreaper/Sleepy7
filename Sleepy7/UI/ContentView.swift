import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var engine: GameEngine
    @EnvironmentObject private var session: AppSession

    @State private var showGame = false
    @State private var showRules = false
    @State private var showStats = false
    @State private var showStore = false
    @State private var showPrivacySheet = false
    @State private var acknowledgedGameCenterDisclosure = GameCenterManager.shared.hasAcknowledgedDisplayNameDisclosure()

    var body: some View {
        NavigationStack {
            ScreenContainer(
                title: "Sleepy7",
                subtitle: "Casino-night energy, modern SwiftUI polish, and monetization that at least pretends to respect civilization."
            ) {
                heroSection

                SectionCard(title: "Quick Play", systemImage: "play.circle.fill") {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        CasinoButton("Start 3-Player Game", systemImage: "shuffle") {
                            engine.startNewGame(playerCount: 3)
                            showGame = true
                        }

                        CasinoButton("Start 4-Player Game", systemImage: "person.3.fill", style: .secondary) {
                            engine.startNewGame(playerCount: 4)
                            showGame = true
                        }
                    }
                }

                SectionCard(title: "Game Hub", systemImage: "suit.spade.fill") {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        CasinoButton("Stats", systemImage: "chart.bar.fill", style: .secondary) {
                            showStats = true
                        }

                        CasinoButton("Rules", systemImage: "book.fill", style: .secondary) {
                            showRules = true
                        }

                        CasinoButton("Store", systemImage: "bag.fill", style: .secondary) {
                            showStore = true
                        }
                    }
                }

                SectionCard(title: "Trust & Permissions", systemImage: "checkmark.shield.fill") {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        DisclosureNoticeCard(
                            title: "Purchases",
                            bodyText: DesignSystem.Copy.purchaseDisclosure,
                            systemImage: "creditcard.fill"
                        )

                        DisclosureNoticeCard(
                            title: "Ads",
                            bodyText: DesignSystem.Copy.adConsentDisclosure,
                            systemImage: "hand.raised.square.fill"
                        )

                        DisclosureNoticeCard(
                            title: "Game Center name",
                            bodyText: DesignSystem.Copy.gameCenterDisclosure,
                            systemImage: "person.crop.circle.badge.checkmark"
                        )

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            CasinoButton(
                                acknowledgedGameCenterDisclosure ? "Game Center Notice Saved" : "Acknowledge GC Name Use",
                                systemImage: "gamecontroller.fill",
                                style: .secondary,
                                isEnabled: !acknowledgedGameCenterDisclosure
                            ) {
                                GameCenterManager.shared.acknowledgeDisplayNameDisclosure()
                                acknowledgedGameCenterDisclosure = true
                            }

                            CasinoButton("Privacy Details", systemImage: "doc.text.magnifyingglass", style: .secondary) {
                                showPrivacySheet = true
                            }
                        }
                    }
                }

                SectionCard(title: "Today’s Table", systemImage: "sparkles") {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            StatPill(label: "Rounds", value: "\(engine.roundNumber)", accent: DesignSystem.Colors.accent)
                            StatPill(label: "Players", value: "\(engine.players.count)", accent: DesignSystem.Colors.info)
                        }

                        if session.shouldShowAds {
                            AdPlaceholderView(
                                title: "Sponsored Seat",
                                subtitle: "Reserved space for a future banner ad after consent and entitlement checks.",
                                systemImage: "rectangle.bottomthird.inset.filled",
                                showConsentBadge: true
                            )
                        } else {
                            DisclosureNoticeCard(
                                title: "Ad-Free Active",
                                bodyText: "Banner and rewarded ad placements are suppressed for this account state.",
                                systemImage: "nosign"
                            )
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showGame) {
                GameView()
            }
            .sheet(isPresented: $showRules) {
                RulesView()
            }
            .sheet(isPresented: $showStats) {
                StatsScreenView()
            }
            .sheet(isPresented: $showStore) {
                StoreView()
                    .environmentObject(session)
            }
            .sheet(isPresented: $showPrivacySheet) {
                PrivacyInfoView()
                    .environmentObject(session)
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Casino-night energy. SwiftUI precision.")
                    .font(DesignSystem.Typography.numberHero)
                    .foregroundStyle(LinearGradient.accentGold)
                    .minimumScaleFactor(0.75)
                    .accessibilityAddTraits(.isHeader)

                Text("Three things users find irresistible: responsive layouts, smooth interactions, and this interface.")
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: DesignSystem.Spacing.sm) {
                Label("Dark mode first", systemImage: "moon.stars.fill")
                Label("Dynamic Type", systemImage: "textformat.size")
                Label("Consent-aware", systemImage: "checkmark.shield")
            }
            .font(DesignSystem.Typography.captionStrong)
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.surfaceElevated,
                            DesignSystem.Colors.surface
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.xl, style: .continuous)
                .stroke(DesignSystem.Colors.accent.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: DesignSystem.Colors.accent.opacity(0.14), radius: 18, x: 0, y: 10)
    }
}