import Foundation

@MainActor
final class AppRouter: ObservableObject {
    enum Route: Hashable {
        case onboarding
        case home
        case game
        case rules
        case summary
    }

    @Published var path: [Route] = []

    func goToHome() {
        path = [.home]
    }

    func startGame() {
        path = [.game]
    }

    func showRules() {
        path.append(.rules)
    }

    func showSummary() {
        path.append(.summary)
    }

    func resetToOnboarding() {
        path = [.onboarding]
    }
}