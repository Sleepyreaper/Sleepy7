import Foundation
import CryptoKit

enum GameSecurityError: Error, Equatable {
    case invalidPayload
    case signatureFailure
    case verificationFailure
}

struct SignedGameStatePayload: Codable, Sendable, Equatable {
    let payload: Data
    let signature: Data
}

struct GameStateSigner: Sendable {
    private let privateKey: P256.Signing.PrivateKey
    private let publicKey: P256.Signing.PublicKey

    init(privateKey: P256.Signing.PrivateKey = .init()) {
        self.privateKey = privateKey
        self.publicKey = privateKey.publicKey
    }

    func sign(_ state: GameState) throws -> SignedGameStatePayload {
        let encoded = try JSONEncoder().encode(state)
        let sig = try privateKey.signature(for: encoded)
        return SignedGameStatePayload(payload: encoded, signature: sig.derRepresentation)
    }

    func verifyAndDecode(_ signed: SignedGameStatePayload) throws -> GameState {
        let signature: P256.Signing.ECDSASignature
        do {
            signature = try .init(derRepresentation: signed.signature)
        } catch {
            throw GameSecurityError.signatureFailure
        }

        guard publicKey.isValidSignature(signature, for: signed.payload) else {
            throw GameSecurityError.verificationFailure
        }

        do {
            return try JSONDecoder().decode(GameState.self, from: signed.payload)
        } catch {
            throw GameSecurityError.invalidPayload
        }
    }
}