import AppTrackingTransparency
import Foundation
import GoogleMobileAds
import UIKit
import UserMessagingPlatform

public protocol AdServing {
    func start() async
    func bannerAdUnitID() -> String
    func rewardedAdUnitID() -> String
    func makeRequest(nonPersonalized: Bool) -> GADRequest
}

@MainActor
public final class AdService: NSObject, AdServing {
    public override init() { super.init() }

    public func start() async {
        await requestConsentIfRequired()
        await requestATT()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    public func bannerAdUnitID() -> String {
        #if DEBUG
        "ca-app-pub-3940256099942544/2934735716"
        #else
        (Bundle.main.object(forInfoDictionaryKey: "ADMOB_BANNER_UNIT_ID") as? String) ?? ""
        #endif
    }

    public func rewardedAdUnitID() -> String {
        #if DEBUG
        "ca-app-pub-3940256099942544/1712485313"
        #else
        (Bundle.main.object(forInfoDictionaryKey: "ADMOB_REWARDED_UNIT_ID") as? String) ?? ""
        #endif
    }

    public func makeRequest(nonPersonalized: Bool) -> GADRequest {
        let request = GADRequest()
        if nonPersonalized {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        return request
    }

    // MARK: Private

    private func requestATT() async {
        guard #available(iOS 14, *) else { return }
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }

    private func requestConsentIfRequired() async {
        let params = UMPRequestParameters()
        do {
            try await withCheckedThrowingContinuation { cont in
                UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: params) { err in
                    err == nil ? cont.resume() : cont.resume(throwing: err!)
                }
            }

            guard UMPConsentInformation.sharedInstance.formStatus == .available else { return }
            let root = await topViewController()
            let form = try await UMPConsentForm.load()
            try await form.present(from: root)
        } catch {
            print("Consent flow skipped/failed: \(error)")
        }
    }

    private func topViewController(
        from root: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController {
        if let nav = root as? UINavigationController { return nav.visibleViewController ?? nav }
        if let tab = root as? UITabBarController { return topViewController(from: tab.selectedViewController) }
        if let presented = root?.presentedViewController { return topViewController(from: presented) }
        return root ?? UIViewController()
    }
}