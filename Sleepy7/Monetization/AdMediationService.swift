import Foundation

final class AdMediationService {
    static let shared = AdMediationService()
    private init() {}

    private var interstitialFrequency: Int = 3
    private var roundsSinceLastInterstitial = 0

    func initialize() {
        // Placeholder: initialize mediation SDK adapters (AdMob/Unity/AppLovin).
    }

    func configureFromRemote(adFrequency: Int?) {
        if let adFrequency, adFrequency > 0 {
            interstitialFrequency = adFrequency
        }
    }

    func showInterstitialIfEligible(context: String) {
        roundsSinceLastInterstitial += 1
        guard roundsSinceLastInterstitial >= interstitialFrequency else { return }

        // Placeholder: show ad from selected mediation provider.
        // Reset only after ad actually shown in real integration.
        roundsSinceLastInterstitial = 0
        _ = context
    }

    func preloadRewarded() {
        // Placeholder: preload rewarded ad unit.
    }
}