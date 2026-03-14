import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        NavigationStack(path: $container.router.path) {
            Color.clear
                .navigationDestination(for: AppRouter.Route.self) { route in
                    switch route {
                    case .onboarding:
                        OnboardingFlowView(
                            viewModel: OnboardingViewModel(
                                onboardingStore: container.onboardingStore,
                                router: container.router,
                                haptics: container.haptics
                            )
                        )
                    case .home:
                        HomeView(
                            viewModel: HomeViewModel(
                                router: container.router,
                                gameSession: container.gameSession,
                                haptics: container.haptics
                            )
                        )
                    case .game:
                        GameScreenView(
                            viewModel: GameViewModel(
                                session: container.gameSession,
                                turnUpdates: container.turnUpdates,
                                haptics: container.haptics,
                                router: container.router
                            )
                        )
                    case .rules:
                        RulesHubView()
                    case .summary:
                        SummaryPlaceholderView()
                    }
                }
                .onAppear {
                    if container.router.path.isEmpty {
                        if container.onboardingStore.hasSeenOnboarding {
                            container.router.goHome()
                        } else {
                            container.router.resetOnboarding()
                        }
                    }
                }
        }
    }
}

private struct SummaryPlaceholderView: View {
    var body: some View {
        ZStack {
            LuxuryBackgroundView()
            GlassCard {
                VStack(spacing: 12) {
                    Text("Round Summary")
                        .font(.largeTitle.weight(.bold))
                    Text("Gil will wire the final post-round model here.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: 480)
            }
            .padding(24)
        }
    }
}