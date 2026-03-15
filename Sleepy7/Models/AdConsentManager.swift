import Foundation
import AppTrackingTransparency
import AdSupport

@MainActor
final class AdConsentManager: ObservableObject {
    enum ConsentStatus: String {
        case unknown
        case required
        case obtained
        case denied
        case notRequired
    }

    @Published private(set) var consentStatus: ConsentStatus = .unknown
    @Published private(set) var trackingStatusDescription: String = "Not determined"
    @Published private(set) var canRequestPersonalizedAds = false
    @Published private(set) var hasCompletedConsentFlow = false

    private let consentStatusKey = "adConsentStatus"
    private let personalizedAdsKey = "personalizedAdsAllowed"

    init() {
        loadCachedState()
    }

    func prepareForAds() async {
        await requestConsentIfNeeded()
        await requestTrackingIfNeeded()
        hasCompletedConsentFlow = true
    }

    func requestConsentIfNeeded() async {
        if consentStatus == .obtained || consentStatus == .denied || consentStatus == .notRequired {
            return
        }

        // Placeholder for UMP SDK integration.
        // In production:
        // 1. Request UMP consent info update.
        // 2. Present form if required.
        // 3. Persist result and pass non-personalized ad flags as needed.
        consentStatus = .required
        canRequestPersonalizedAds = false
        persistState()
    }

    func grantNonPersonalizedConsent() {
        consentStatus = .obtained
        canRequestPersonalizedAds = false
        persistState()
    }

    func grantPersonalizedConsent() {
        consentStatus = .obtained
        canRequestPersonalizedAds = true
        persistState()
    }

    func denyConsent() {
        consentStatus = .denied
        canRequestPersonalizedAds = false
        persistState()
    }

    func requestTrackingIfNeeded() async {
        guard #available(iOS 14, *) else {
            trackingStatusDescription = "Unavailable"
            return
        }

        let status = ATTrackingManager.trackingAuthorizationStatus
        if status == .notDetermined {
            let result = await withCheckedContinuation { continuation in
                ATTrackingManager.requestTrackingAuthorization { response in
                    continuation.resume(returning: response)
                }
            }
            trackingStatusDescription = describeTrackingStatus(result)
        } else {
            trackingStatusDescription = describeTrackingStatus(status)
        }

        if ATTrackingManager.trackingAuthorizationStatus != .authorized {
            canRequestPersonalizedAds = false
            persistState()
        }
    }

    var shouldRequestNonPersonalizedAds: Bool {
        hasCompletedConsentFlow && !canRequestPersonalizedAds
    }

    private func describeTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not determined"
        @unknown default: return "Unknown"
        }
    }

    private func loadCachedState() {
        if let raw = UserDefaults.standard.string(forKey: consentStatusKey),
           let status = ConsentStatus(rawValue: raw) {
            consentStatus = status
        }

        canRequestPersonalizedAds = UserDefaults.standard.bool(forKey: personalizedAdsKey)
    }

    private func persistState() {
        UserDefaults.standard.set(consentStatus.rawValue, forKey: consentStatusKey)
        UserDefaults.standard.set(canRequestPersonalizedAds, forKey: personalizedAdsKey)
    }
}