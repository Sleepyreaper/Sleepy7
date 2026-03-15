import Foundation

enum Monitoring {
    static func appLaunch() {
        FirebaseBootstrap.log("app_launch")
    }

    static func roundStarted(roundNumber: Int, playerCount: Int) {
        FirebaseBootstrap.log("round_started")
        FirebaseBootstrap.setUserContext(playerCount: playerCount, roundNumber: roundNumber)
    }

    static func purchaseAttempt(productID: String) {
        FirebaseBootstrap.log("purchase_attempt:\(productID)")
    }

    static func purchaseSuccess(productID: String) {
        FirebaseBootstrap.log("purchase_success:\(productID)")
    }

    static func adLoad(unit: String) {
        FirebaseBootstrap.log("ad_load:\(unit)")
    }

    static func adFailure(unit: String, message: String) {
        FirebaseBootstrap.log("ad_failure:\(unit):\(message)")
    }
}