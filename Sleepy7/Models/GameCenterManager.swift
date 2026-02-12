import GameKit

class GameCenterManager: NSObject {
    static let shared = GameCenterManager()
    
    var presentAuthViewController: ((UIViewController) -> Void)?
    
    override init() {
        super.init()
    }
    
    func getLocalPlayerName() -> String? {
        let displayName = GKLocalPlayer.local.displayName
        if !displayName.isEmpty {
            return displayName
        }
        return nil
    }
    
    func authenticatePlayer(completion: @escaping (Bool) -> Void) {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                // User needs to authenticate - present the view controller
                DispatchQueue.main.async {
                    self?.presentAuthViewController?(viewController)
                }
            } else if error != nil {
                print("Game Center authentication failed: \(error?.localizedDescription ?? "")")
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
