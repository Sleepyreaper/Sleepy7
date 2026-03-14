import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    struct Page: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let body: String
        let symbol: String
    }

    @Published var currentPage: Int = 0

    let pages: [Page] = [
        Page(
            title: "Collect unique numbers",
            body: "Each hit reveals a card. Unique number cards build your round score. Duplicates are dangerous.",
            symbol: "square.stack.3d.up.fill"
        ),
        Page(
            title: "Duplicate? You bust",
            body: "If you draw a number you already hold, your round usually ends with zero points—unless a Second Chance saves you.",
            symbol: "burst.fill"
        ),
        Page(
            title: "Action and modifier cards matter",
            body: "Freeze opponents, protect a risky round, and stack bonuses to turn a decent hand into a luxury scoreline.",
            symbol: "sparkles.rectangle.stack.fill"
        ),
        Page(
            title: "Reach Flip 7",
            body: "Land seven unique numbers to trigger the signature moment: Flip 7. High drama. Higher bragging rights.",
            symbol: "crown.fill"
        )
    ]

    private let onboardingStore: OnboardingStoring
    private let router: AppRouter
    private let haptics: HapticProviding

    init(
        onboardingStore: OnboardingStoring,
        router: AppRouter,
        haptics: HapticProviding
    ) {
        self.onboardingStore = onboardingStore
        self.router = router
        self.haptics = haptics
    }

    func advance() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            haptics.impactLight()
        } else {
            finish()
        }
    }

    func skip() {
        finish()
    }

    func finish() {
        onboardingStore.hasSeenOnboarding = true
        haptics.notifySuccess()
        router.goToHome()
    }
}