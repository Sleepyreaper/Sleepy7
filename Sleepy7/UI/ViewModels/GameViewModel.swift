import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state = GameScreenState()

    private let session: GameSessionProviding
    private let turnUpdates: GameTurnUpdateProviding
    private let haptics: HapticProviding
    private let router: AppRouter

    private var stateTask: Task<Void, Never>?
    private var turnTask: Task<Void, Never>?

    init(
        session: GameSessionProviding,
        turnUpdates: GameTurnUpdateProviding,
        haptics: HapticProviding,
        router: AppRouter
    ) {
        self.session = session
        self.turnUpdates = turnUpdates
        self.haptics = haptics
        self.router = router
        bind()
    }

    deinit {
        stateTask?.cancel()
        turnTask?.cancel()
    }

    func bind() {
        stateTask?.cancel()
        turnTask?.cancel()

        stateTask = Task { [weak self] in
            guard let self else { return }
            for await snapshot in session.stateStream() {
                self.state = Self.map(snapshot: snapshot, previous: self.state)
                self.state.isLoading = false
                if snapshot.isGameOver {
                    self.router.showSummary()
                }
            }
        }

        turnTask = Task { [weak self] in
            guard let self else { return }
            for await update in turnUpdates.turnUpdates() {
                self.state.banner = TurnBannerViewData(
                    id: update.id,
                    text: update.message,
                    kind: update.kind
                )

                switch update.kind {
                case .info:
                    haptics.impactLight()
                case .success:
                    haptics.notifySuccess()
                case .warning:
                    haptics.notifyWarning()
                }
            }
        }
    }

    func hit() {
        guard state.isHitEnabled, !state.isAwaitingNetwork else { return }

        state.isAwaitingNetwork = true
        state.errorMessage = nil

        Task {
            do {
                try await session.hit()
                haptics.impactMedium()
            } catch {
                state.errorMessage = "Hit failed. Check your connection and try again."
                haptics.notifyError()
            }
            state.isAwaitingNetwork = false
        }
    }

    func stay() {
        guard state.isStayEnabled, !state.isAwaitingNetwork else { return }

        state.isAwaitingNetwork = true
        state.errorMessage = nil

        Task {
            do {
                try await session.stay()
                haptics.notifySuccess()
            } catch {
                state.errorMessage = "Stay failed. Check your connection and try again."
                haptics.notifyError()
            }
            state.isAwaitingNetwork = false
        }
    }

    func dismissBanner() {
        state.banner = nil
    }

    private static func map(snapshot: GameSnapshot, previous: GameScreenState) -> GameScreenState {
        GameScreenState(
            title: snapshot.title,
            subtitle: snapshot.subtitle,
            players: snapshot.players.map {
                PlayerSeatViewData(
                    id: $0.id,
                    name: $0.name,
                    totalScore: $0.totalScore,
                    roundScore: $0.roundScore,
                    isActive: $0.isActive,
                    isFrozen: $0.isFrozen,
                    isBusted: $0.isBusted,
                    cardCount: $0.cardCount,
                    badgeText: $0.badgeText
                )
            },
            currentHand: snapshot.hand.map {
                TableCardViewData(
                    id: $0.id,
                    title: $0.title,
                    subtitle: $0.subtitle,
                    assetName: $0.assetName,
                    accessibilityLabel: $0.accessibilityLabel
                )
            },
            deckCount: snapshot.deckCount,
            isLoading: false,
            isHitEnabled: snapshot.canHit,
            isStayEnabled: snapshot.canStay,
            isAwaitingNetwork: previous.isAwaitingNetwork,
            banner: previous.banner,
            errorMessage: previous.errorMessage,
            isGameOver: snapshot.isGameOver
        )
    }
}