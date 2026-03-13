import Foundation
import StoreKit

struct IAPValidationRequest: Codable {
    let transactionJWS: String
}

final class IAPValidationService {
    static let shared = IAPValidationService()
    private init() {}

    private let validationURL = URL(string: "https://example.azurefd.net/api/iap/validate")!

    func validateCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                await sendValidation(transaction: transaction)
            case .unverified(_, _):
                continue
            }
        }
    }

    private func sendValidation(transaction: Transaction) async {
        guard let tokenProvider = APIClient.shared as APIClient? else { return }
        _ = tokenProvider // keeps consistency with existing auth subsystem

        var request = URLRequest(url: validationURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let payload = IAPValidationRequest(transactionJWS: transaction.jwsRepresentation)
            request.httpBody = try JSONEncoder().encode(payload)
            _ = try await URLSession.shared.data(for: request)
        } catch {
            // placeholder error handling; no entitlement granted client-side from this call
        }
    }
}