import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isStartingGame = false
    @Published var errorMessage: String?

    private let router: AppRouter
    private let gameSession: GameSessionProviding
    private let haptics: HapticProviding

    init(
        router: AppRouter,
        gameSession: GameSessionProviding,
        haptics: HapticProviding
    ) {
        self.router = router
        self.gameSession = gameSession
        self.haptics = haptics
    }

    func startGame() {
        Task {
            isStartingGame = true
            errorMessage = nil
            do {
                try await gameSession.startNewMatch()
                haptics.notifySuccess()
                router.startGame()
            } catch {
                errorMessage = "Unable to start a new match. Please try again."
                haptics.notifyError()
            }
            isStartingGame = false
        }
    }

    func showRules() {
        haptics.impactLight()
        router.showRules()
    }
}