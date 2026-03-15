import Foundation
import StoreKit

// … existing imports & typealiases …

public protocol EntitlementValidating: Sendable {
    func verifySignedTransaction(_ signedJWS: String, appAccountToken: UUID?) async throws -> Set<String>
}

public protocol EntitlementStore: Sendable {
    func save(entitlements: Set<String>) async throws
    func load() async throws -> Set<String>
}

// …

public actor IAPManager {
    // keep existing properties

    // MARK: - Purchase Flow (patched sections only)

    public func purchase(productID: String, appAccountToken: UUID? = nil) async throws {
        // … unchanged pre-amble …

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            try validateEnvironment(transaction.environment)
            await transaction.finish()

            // Persist the signed JWS locally for server validation
            if let signed = transaction.signedData {
                try await storeSignedJWS(signed, for: productID)
            }

            // Local optimistic entitlement
            purchasedIDs.insert(productID)

            // Server-side validation
            if let signed = transaction.signedData,
               let validator {
                let serverEntitlements = try await validator.verifySignedTransaction(
                    signed,
                    appAccountToken: appAccountToken
                )
                purchasedIDs.formUnion(serverEntitlements)
            }

            try await store?.save(entitlements: purchasedIDs)
            uiHandler?.onPurchaseSuccess(productID: productID)

        // … remainder unchanged …
        }
    }

    public func validateReceipt(productID: String) async -> Bool {
        if let validator,
           let signed = try? await loadSignedJWS(for: productID),
           let serverSet = try? await validator.verifySignedTransaction(signed, appAccountToken: nil) {
            return serverSet.contains(productID)
        }
        return purchasedIDs.contains(productID)
    }

    // MARK: - Helpers to persist signed JWS blobs (simple FileManager demo)

    private func jwsURL(for productID: String) -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("\(productID).jws")
    }

    private func storeSignedJWS(_ jws: String, for productID: String) throws {
        try jws.data(using: .utf8)?.write(to: jwsURL(for: productID), options: .atomic)
    }

    private func loadSignedJWS(for productID: String) async throws -> String {
        let data = try Data(contentsOf: jwsURL(for: productID))
        guard let str = String(data: data, encoding: .utf8) else { throw IAPError.unverifiedTransaction }
        return str
    }

    private func validateEnvironment(_ environment: AppStore.Environment) throws {
        guard environment == expectedEnvironment else { throw IAPError.invalidEnvironment }
    }
}