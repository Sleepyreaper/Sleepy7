import Foundation
import FirebaseCore
import FirebaseCrashlytics
import FirebasePerformance

enum FirebaseBootstrap {
    static func configure() {
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()

        #if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
        Performance.sharedInstance().isDataCollectionEnabled = false
        #else
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        Performance.sharedInstance().isDataCollectionEnabled = true
        #endif

        Crashlytics.crashlytics().setCustomValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown", forKey: "app_version")
        Crashlytics.crashlytics().setCustomValue(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown", forKey: "build_number")
    }

    static func setUserContext(playerCount: Int, roundNumber: Int) {
        Crashlytics.crashlytics().setCustomValue(playerCount, forKey: "player_count")
        Crashlytics.crashlytics().setCustomValue(roundNumber, forKey: "round_number")
    }

    static func record(error: Error, reason: String? = nil) {
        let nsError = error as NSError
        Crashlytics.crashlytics().record(error: nsError)
        if let reason, !reason.isEmpty {
            Crashlytics.crashlytics().log(reason)
        }
    }

    static func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
}