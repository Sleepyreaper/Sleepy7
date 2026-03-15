import Foundation
import StoreKit

@MainActor
final class IAPManager: ObservableObject {
    // … existing code & properties …

    // MARK: – Helpers -------------------------------------------------

    /// Ensures the transaction’s environment matches the build’s expectation.
    private func isTransactionEnvironmentAllowed(_ transaction: Transaction) -> Bool {
        #if DEBUG
        return true      // Accept sandbox & production while debugging
        #else
        return transaction.environment == .production
        #endif
    }

    // … existing helpers …

    // PATCH: make Entitlement persistence async-safe
    private func persistPurchasedIDs(_ ids: Set<String>) {
        guard let data = try? JSONEncoder().encode(Array(ids)) else { return }
        _ = KeychainHelper.save(data, service: keychainService, account: keychainAccount)
    }

    private func loadCachedEntitlements() {
        if let data = KeychainHelper.read(service: keychainService, account: keychainAccount),
           let array = try? JSONDecoder().decode([String].self, from: data) {
            purchasedIDs = Set(array)
        }
    }

    private func verifyTransactionWithServerIfConfigured(_ tx: Transaction) async throws {
        guard let signed = tx.signedData else { throw PurchaseError.missingSignedPayload }

        // If you have a validator, call it; else return.
        // (Stub – to be wired to real backend.)
        /*
        let serverOK = try await MyEntitlementValidator.shared.verify(signedJWS: signed)
        guard serverOK else { throw PurchaseError.serverRejected }
        */
    }

    // Existing checkVerified remains unchanged
}