import SwiftUI

struct GameView: View {
    @EnvironmentObject private var engine: GameEngine
    @EnvironmentObject private var session: AppSession
    @Environment(\.dismiss) private var dismiss

    @State private var showRewardPrompt = false
    @State private var rewardLoading = false
    @State private var showPrivacySheet = false

    var body: some View {
        ZStack {
            LinearGradient.casinoBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        roundSummary
                        playersSection
                        actionsSection
                        statusSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                    .frame(maxWidth: DesignSystem.Layout.maxContentWidth)
                    .frame(maxWidth: .infinity)
                }

                if session.shouldShowAds {
                    bottomBanner
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.sm)
                }
            }

            if showRewardPrompt {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showRewardPrompt = false
                    }

                RewardedSecondChancePrompt(
                    isLoading: rewardLoading,
                    consentReady: session.canShowRewardedSecondChance,
                    onWatchAd: simulateRewardedSecondChance,
                    onDismiss: { showRewardPrompt = false },
                    onReviewPrivacy: { showPrivacySheet = true }
                )
                .padding(DesignSystem.Spacing.lg)
                .frame(maxWidth: 560)
                .transition(.scale.combined(with: .opacity))
                .zIndex(2)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.spring(response: 0.34, dampingFraction: 0.88), value: showRewardPrompt)
        .onChange(of: engine.roundEndedReason) { _, newValue in
            guard let newValue else { return }
            if newValue.localizedCaseInsensitiveContains("bust"), session.shouldShowAds {
                showRewardPrompt = true
            }
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyInfoView()
                .environmentObject(session)
        }
    }

    private var header: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(DesignSystem.Colors.surfaceElevated)
                    )
            }
            .accessibilityLabel("Back to main menu")

            VStack(alignment: .leading, spacing: 2) {
                Text("Round \(engine.roundNumber)")
                    .font(DesignSystem.Typography.title3)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)

                Text(engine.activePlayerName ?? "Waiting for table")
                    .font(DesignSystem.Typography.footnote)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Deck")
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.textMuted)

                Text("\(engine.remainingDeckCount)")
                    .font(DesignSystem.Typography.title3)
                    .foregroundStyle(DesignSystem.Colors.accent)
                    .accessibilityLabel("\(engine.remainingDeckCount) cards remaining in deck")
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.background.opacity(0.55))
    }

    private var roundSummary: some View {
        SectionCard(title: "Table Summary", systemImage: "suit.club.fill") {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    StatPill(label: "Players", value: "\(engine.players.count)", accent: DesignSystem.Colors.info)
                    StatPill(label: "Dealer", value: dealerName, accent: DesignSystem.Colors.accent)
                }

                if let reason = engine.roundEndedReason, !reason.isEmpty {
                    bannerText(reason, color: DesignSystem.Colors.warning, icon: "exclamationmark.triangle.fill")
                }

                if let winnerName = engine.winnerName, !winnerName.isEmpty {
                    bannerText("\(winnerName) wins the round", color: DesignSystem.Colors.success, icon: "crown.fill")
                }

                if !engine.lastAction.isEmpty {
                    bannerText(engine.lastAction, color: DesignSystem.Colors.info, icon: "sparkles")
                }
            }
        }
    }

    private var playersSection: some View {
        SectionCard(title: "Players", systemImage: "person.3.sequence.fill") {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(Array(engine.players.enumerated()), id: \.element.id) { index, player in
                    let hand = engine.hand(for: player)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(player.name)
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)

                                Text(statusText(for: hand, isActive: index == engine.activePlayerIndex))
                                    .font(DesignSystem.Typography.footnote)
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                            }

                            Spacer()

                            Text("\(engine.roundScore(for: player))")
                                .font(DesignSystem.Typography.title2)
                                .foregroundStyle(index == engine.activePlayerIndex ? DesignSystem.Colors.accent : DesignSystem.Colors.textPrimary)
                                .accessibilityLabel("\(player.name) score \(engine.roundScore(for: player))")
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                ForEach(Array(hand.numberCards.enumerated()), id: \.offset) { _, value in
                                    chip(value: "\(value)", color: DesignSystem.Colors.info)
                                }

                                ForEach(Array(hand.modifiers.enumerated()), id: \.offset) { _, modifier in
                                    chip(value: modifier.rawValue, color: DesignSystem.Colors.accent)
                                }

                                if hand.hasSecondChance {
                                    chip(value: "2nd", color: DesignSystem.Colors.success)
                                }

                                if hand.flippedSeven {
                                    chip(value: "Flip 7", color: DesignSystem.Colors.warning)
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                            .fill(index == engine.activePlayerIndex ? DesignSystem.Colors.surfaceElevated : DesignSystem.Colors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                            .stroke(index == engine.activePlayerIndex ? DesignSystem.Colors.accent.opacity(0.35) : Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private var actionsSection: some View {
        SectionCard(title: "Actions", systemImage: "hand.tap.fill") {
            VStack(spacing: DesignSystem.Spacing.sm) {
                CasinoButton("Hit", systemImage: "plus.circle.fill", style: .primary, isEnabled: engine.canAct && !engine.isActivePlayerAI) {
                    performEngineAction(named: "hit")
                }

                HStack(spacing: DesignSystem.Spacing.sm) {
                    CasinoButton("Stay", systemImage: "pause.circle.fill", style: .secondary, isEnabled: engine.canAct && !engine.isActivePlayerAI) {
                        performEngineAction(named: "stay")
                    }

                    CasinoButton("New Game", systemImage: "arrow.clockwise.circle.fill", style: .secondary) {
                        engine.startNewGame(playerCount: max(engine.players.count, 3))
                    }
                }
            }
        }
    }

    private var statusSection: some View {
        SectionCard(title: "Status", systemImage: "waveform.path.ecg") {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                if let lastCard = engine.lastDrawnCard {
                    Text("Last draw: \(describe(card: lastCard))")
                        .font(DesignSystem.Typography.body)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                } else {
                    Text("No cards drawn yet this turn.")
                        .font(DesignSystem.Typography.body)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }

                if engine.pendingFreezeAction {
                    Text("Freeze action pending target selection.")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundStyle(DesignSystem.Colors.warning)
                }

                if let frozenPlayerName = engine.frozenPlayerName {
                    Text("\(frozenPlayerName) was frozen.")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundStyle(DesignSystem.Colors.info)
                }

                if let flippedSevenPlayerName = engine.flippedSevenPlayerName {
                    Text("\(flippedSevenPlayerName) flipped seven.")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundStyle(DesignSystem.Colors.success)
                }

                if session.iapManager.isAdFree {
                    DisclosureNoticeCard(
                        title: "Ad-Free Enabled",
                        bodyText: "Rewarded and banner placements are disabled because this upgrade is active.",
                        systemImage: "nosign"
                    )
                }
            }
        }
    }

    private var bottomBanner: some View {
        AdPlaceholderView(
            title: "Banner Placement",
            subtitle: "Future gameplay banner area. Hidden for Ad-Free users and shown only after applicable consent handling.",
            systemImage: "rectangle.bottomthird.inset.filled",
            showConsentBadge: true
        )
        .padding(.top, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.background.opacity(0.01))
    }

    private var dealerName: String {
        guard engine.players.indices.contains(engine.dealerIndex) else { return "—" }
        return engine.players[engine.dealerIndex].name
    }

    private func bannerText(_ text: String, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(text)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                .fill(color.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md, style: .continuous)
                .stroke(color.opacity(0.24), lineWidth: 1)
        )
    }

    private func chip(value: String, color: Color) -> some View {
        Text(value)
            .font(DesignSystem.Typography.captionStrong)
            .foregroundStyle(DesignSystem.Colors.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.18))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(color.opacity(0.35), lineWidth: 1)
            )
    }

    private func statusText(for hand: RoundHand, isActive: Bool) -> String {
        if hand.isBusted { return "Busted" }
        if hand.isFrozen { return "Frozen" }
        if hand.isStayed { return "Stayed" }
        if isActive { return "Active turn" }
        return "Waiting"
    }

    private func describe(card: Card) -> String {
        switch card.kind {
        case .number(let value):
            return "Number \(value)"
        case .action(let action):
            return action.rawValue
        case .modifier(let modifier):
            return modifier.rawValue
        }
    }

    private func performEngineAction(named action: String) {
        engine.lastAction = action.capitalized
    }

    private func simulateRewardedSecondChance() {
        guard session.canShowRewardedSecondChance else {
            showPrivacySheet = true
            return
        }

        rewardLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            rewardLoading = false
            showRewardPrompt = false
            engine.lastAction = "Rewarded Second Chance granted"
        }
    }
}