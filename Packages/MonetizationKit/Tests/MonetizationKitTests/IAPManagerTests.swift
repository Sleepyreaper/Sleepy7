import XCTest
@testable import MonetizationKit

actor InMemoryStore: EntitlementStore {
    private var storage = Set<String>()
    func save(entitlements: Set<String>) async throws { storage = entitlements }
    func load() async throws -> Set<String> { storage }
}

struct MockValidator: EntitlementValidating {
    let entitlements: Set<String>
    func verifySignedTransaction(_: String, appAccountToken _: UUID?) async throws -> Set<String> {
        entitlements
    }
}

final class IAPManagerTests: XCTestCase {
    func testServerValidationPath() async throws {
        let store = InMemoryStore()
        let validator = MockValidator(entitlements: [IAPManager.removeAds])
        let sut = IAPManager(validator: validator, store: store, expectedEnvironment: .sandbox)

        // Simulate server saying user owns "remove_ads"
        let valid = await sut.validateReceipt(productID: IAPManager.removeAds)
        XCTAssertTrue(valid)
    }
}