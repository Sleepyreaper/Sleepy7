import UIKit

protocol HapticProviding: AnyObject {
    func impactLight()
    func impactMedium()
    func notifySuccess()
    func notifyWarning()
    func notifyError()
}

final class HapticManager: HapticProviding {
    func impactLight()   { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    func impactMedium()  { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    func notifySuccess() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func notifyWarning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    func notifyError()   { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}