import Foundation

@MainActor
final class AppSession: ObservableObject {
    @Published var iapManager: IAPManager
    @Published var adConsentManager: AdConsentManager

    init(
        iapManager: IAPManager = IAPManager(),
        adConsentManager: AdConsentManager = AdConsentManager()
    ) {
        self.iapManager = iapManager
        self.adConsentManager = adConsentManager
    }

    var shouldShowAds: Bool {
        !iapManager.isAdFree
    }

    var canShowRewardedSecondChance: Bool {
        shouldShowAds && adConsentManager.hasCompletedConsentFlow
    }

    func bootstrapMonetization() async {
        await iapManager.loadProducts()
        await iapManager.refreshEntitlements()
        await adConsentManager.prepareForAds()
    }
}