import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack {
            LuxuryBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    menuCards
                }
                .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 16 : 24)
                .padding(.vertical, 24)
                .frame(maxWidth: 860)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Sleepy7")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)

                Text("Push your luck in a casino-lux card room built for one more turn.")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Label("Adaptive iPhone + iPad UI", systemImage: "iphone.gen3.radiowaves.left.and.right")
                    Label("Dark mode included", systemImage: "moon.stars.fill")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sleepy7 main menu")
    }

    private var menuCards: some View {
        ViewThatFits(in: .vertical) {
            HStack(spacing: 20) {
                primaryActionCard
                secondaryActionCard
            }
            VStack(spacing: 20) {
                primaryActionCard
                secondaryActionCard
            }
        }
    }

    private var primaryActionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                Text("Start Match")
                    .font(.title2.weight(.bold))

                Text("Launch directly into the card table with premium motion, haptics, and turn updates.")
                    .foregroundStyle(.secondary)

                Button {
                    viewModel.startGame()
                } label: {
                    HStack {
                        if viewModel.isStartingGame {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(viewModel.isStartingGame ? "Starting…" : "Play Now")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(LuxuryPrimaryButtonStyle())
                .disabled(viewModel.isStartingGame)
                .accessibilityHint("Starts a new Sleepy7 match")
            }
        }
    }

    private var secondaryActionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                Text("Learn the Rules")
                    .font(.title2.weight(.bold))

                Text("Animated onboarding explains busts, unique numbers, modifiers, and the glory of Flip 7.")
                    .foregroundStyle(.secondary)

                Button("View Rules") {
                    viewModel.showRules()
                }
                .buttonStyle(LuxurySecondaryButtonStyle())
                .accessibilityHint("Opens the rules and tutorial")
            }
        }
    }
}