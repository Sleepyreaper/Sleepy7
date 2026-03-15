import GameKit
import UIKit

final class GameCenterManager: NSObject {
    static let shared = GameCenterManager()

    var presentAuthViewController: ((UIViewController) -> Void)?

    private let displayNameDisclosureKey = "hasAcknowledgedGameCenterDisplayNameDisclosure"

    override init() {
        super.init()
    }

    func hasAcknowledgedDisplayNameDisclosure() -> Bool {
        UserDefaults.standard.bool(forKey: displayNameDisclosureKey)
    }

    func acknowledgeDisplayNameDisclosure() {
        UserDefaults.standard.set(true, forKey: displayNameDisclosureKey)
    }

    func getLocalPlayerNameIfPermitted() -> String? {
        guard hasAcknowledgedDisplayNameDisclosure() else {
            return nil
        }

        let displayName = GKLocalPlayer.local.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return displayName.isEmpty ? nil : displayName
    }

    func authenticatePlayer(completion: @escaping (Bool) -> Void) {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                DispatchQueue.main.async {
                    self?.presentAuthViewController?(viewController)
                }
            } else if let error {
                print("Game Center authentication failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            } else {
                DispatchQueue.main.async {
                    completion(GKLocalPlayer.local.isAuthenticated)
                }
            }
        }
    }
}