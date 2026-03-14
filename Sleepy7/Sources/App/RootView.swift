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
                                networking: container.networking,
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
                            container.router.goToHome()
                        } else {
                            container.router.resetToOnboarding()
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
            Text("Round Summary")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
        }
    }
}