import Foundation
import SwiftUI

@MainActor
final class AppContainer: ObservableObject {
    let router: AppRouter
    let gameSession: GameSessionProviding
    let turnUpdates: GameTurnUpdateProviding
    let haptics: HapticProviding
    let onboardingStore: OnboardingStoring

    init(
        router: AppRouter,
        gameSession: GameSessionProviding,
        turnUpdates: GameTurnUpdateProviding,
        haptics: HapticProviding,
        onboardingStore: OnboardingStoring
    ) {
        self.router = router
        self.gameSession = gameSession
        self.turnUpdates = turnUpdates
        self.haptics = haptics
        self.onboardingStore = onboardingStore
    }

    static func bootstrap() -> AppContainer {
        let router = AppRouter()
        let gameSession = MockGameSessionService()
        let turnUpdates = MockGameTurnUpdateService()
        let haptics = HapticManager()
        let onboardingStore = UserDefaultsOnboardingStore()

        if onboardingStore.hasSeenOnboarding {
            router.setRoot(.home)
        } else {
            router.setRoot(.onboarding)
        }

        return AppContainer(
            router: router,
            gameSession: gameSession,
            turnUpdates: turnUpdates,
            haptics: haptics,
            onboardingStore: onboardingStore
        )
    }
}