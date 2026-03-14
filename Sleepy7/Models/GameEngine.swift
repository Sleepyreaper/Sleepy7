// … keep all existing content up to the truncated switch …

        case .useFreeze(_, let targetID):
            await freeze(targetPlayerID: targetID)

        case .gameStateSync(let signedPayload):
            await apply(syncPayload: signedPayload)
        }
    }

    // MARK: - Private helpers
    private func apply(syncPayload signed: SignedGameStatePayload) async {
        do {
            let incoming = try signer.verifyAndDecode(signed)
            self.state = incoming
            await broadcast()
        } catch {
            // Invalid payload – ignore or log
        }
    }

    private func freeze(targetPlayerID: UUID) async {
        guard var hand = state.roundHands[targetPlayerID] else { return }
        hand.isFrozen = true
        state.roundHands[targetPlayerID] = hand
        state.lastAction = "Player frozen"
        await broadcast()
    }

    private func register(_ continuation: AsyncStream<GameState>.Continuation, token: UUID) {
        continuations[token] = continuation
        continuation.yield(state)
    }

    private func unregister(token: UUID) {
        continuations[token] = nil
    }

    private func broadcast() async {
        continuations.values.forEach { $0.yield(state) }
        guard let matchClient else { return }
        if let signed = try? signer.sign(state) {
            try? await matchClient.send(.gameStateSync(signed))
        }
    }
}