import SwiftUI

struct GameScreenView: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack {
            LuxuryBackgroundView()

            Group {
                if viewModel.state.isLoading {
                    loadingState
                } else {
                    content
                }
            }
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 12 : 20)
            .padding(.vertical, 16)
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .top) {
            if let banner = viewModel.state.transientBanner {
                TurnBannerView(text: banner) {
                    viewModel.dismissBanner()
                }
                .padding(.top, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onChange(of: viewModel.state.isGameOver) { _, _ in
            viewModel.openSummaryIfNeeded()
        }
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact || dynamicTypeSize.isAccessibilitySize
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 18) {
                topSummary

                if isCompact {
                    VStack(spacing: 18) {
                        playerRail
                        handArea
                        actionBar
                    }
                } else {
                    HStack(alignment: .top, spacing: 18) {
                        playerRail
                            .frame(maxWidth: 330)
                        VStack(spacing: 18) {
                            handArea
                            actionBar
                        }
                    }
                }

                if let error = viewModel.state.errorMessage {
                    errorView(error)
                }
            }
            .frame(maxWidth: 1200)
            .frame(maxWidth: .infinity)
        }
    }

    private var loadingState: some View {
        VStack(spacing: 18) {
            ProgressView()
                .controlSize(.large)
            Text("Preparing the table…")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading game table")
    }

    private var topSummary: some View {
        GlassCard {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.state.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))

                    Text(viewModel.state.subtitle)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label("\(viewModel.state.deckCount) cards", systemImage: "square.stack.fill")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.10))
                    .clipShape(Capsule())
                    .accessibilityLabel("Deck has \(viewModel.state.deckCount) cards remaining")
            }
        }
    }

    private var playerRail: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Players")
                    .font(.title3.weight(.bold))

                if viewModel.state.players.isEmpty {
                    ContentUnavailableView(
                        "No Players",
                        systemImage: "person.3.slash",
                        description: Text("Waiting for the match roster.")
                    )
                } else {
                    ForEach(viewModel.state.players) { player in
                        PlayerSeatCard(player: player)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var handArea: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Current Hand")
                    .font(.title3.weight(.bold))

                if viewModel.state.currentHand.isEmpty {
                    ContentUnavailableView(
                        "No Cards Yet",
                        systemImage: "rectangle.stack.badge.plus",
                        description: Text("Hit to reveal your first card.")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                } else {
                    AdaptiveCardGrid(cards: viewModel.state.currentHand)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var actionBar: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    Button {
                        viewModel.hit()
                    } label: {
                        Label("Hit", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(LuxuryPrimaryButtonStyle())
                    .disabled(!viewModel.state.isHitEnabled || viewModel.state.isAwaitingNetwork)
                    .accessibilityHint("Draw another card")

                    Button {
                        viewModel.stay()
                    } label: {
                        Label("Stay", systemImage: "hand.raised.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(LuxurySecondaryButtonStyle())
                    .disabled(!viewModel.state.isStayEnabled || viewModel.state.isAwaitingNetwork)
                    .accessibilityHint("End your turn and keep your round score")
                }

                if viewModel.state.isAwaitingNetwork {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Syncing turn…")
                            .foregroundStyle(.secondary)
                    }
                    .font(.footnote.weight(.medium))
                    .accessibilityLabel("Syncing turn update")
                }
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        GlassCard {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error. \(message)")
    }
}