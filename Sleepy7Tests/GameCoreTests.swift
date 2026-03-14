import XCTest
@testable import Sleepy7

final class GameCoreTests: XCTestCase {

    func testBustWithoutSecondChance() {
        var hand = RoundHand()
        let rules = RulesEngine()

        _ = rules.apply(card: Card(.number(7)), to: &hand)
        let result = rules.apply(card: Card(.number(7)), to: &hand)

        XCTAssertEqual(result, .busted)
        XCTAssertTrue(hand.isBusted)
    }

    func testSecondChancePreventsOneBust() {
        var hand = RoundHand()
        let rules = RulesEngine()

        _ = rules.apply(card: Card(.action(.secondChance)), to: &hand)
        _ = rules.apply(card: Card(.number(5)), to: &hand)
        let duplicateResult = rules.apply(card: Card(.number(5)), to: &hand)

        XCTAssertEqual(duplicateResult, .secondChanceUsed)
        XCTAssertFalse(hand.isBusted)
        XCTAssertFalse(hand.hasSecondChance)
    }

    func testFlipSevenTriggersBonusAndStay() {
        var hand = RoundHand()
        let rules = RulesEngine()

        for value in 0...6 {
            _ = rules.apply(card: Card(.number(value)), to: &hand)
        }

        XCTAssertTrue(hand.flippedSeven)
        XCTAssertTrue(hand.isStayed)
        XCTAssertEqual(rules.score(for: hand), (0 + 1 + 2 + 3 + 4 + 5 + 6) + 15)
    }

    func testModifiersApplyCorrectly() {
        var hand = RoundHand(numberCards: [5, 6], modifiers: [], hasSecondChance: false, isBusted: false, isStayed: false, isFrozen: false, flippedSeven: false)
        let rules = RulesEngine()

        _ = rules.apply(card: Card(.modifier(.times2)), to: &hand)
        _ = rules.apply(card: Card(.modifier(.plus4)), to: &hand)

        XCTAssertEqual(rules.score(for: hand), ((5 + 6) * 2) + 4)
    }

    func testAIExpertStaysAtHighRisk() {
        let ai = AIPlayer(difficulty: .expert)
        let hand = RoundHand(numberCards: [10, 9, 8, 4, 2], modifiers: [], hasSecondChance: false, isBusted: false, isStayed: false, isFrozen: false, flippedSeven: false)

        XCTAssertFalse(ai.shouldHit(hand: hand, roundNumber: 4))
    }

    func testSignedGameStateRoundTripSucceeds() throws {
        let signer = GameStateSigner()
        let players = [Player(name: "A"), Player(name: "B")]
        var hands: [UUID: RoundHand] = [:]
        players.forEach { hands[$0.id] = RoundHand() }

        let state = GameState(
            players: players,
            roundHands: hands,
            roundNumber: 1,
            dealerIndex: 0,
            activePlayerIndex: 0,
            lastAction: "start",
            winnerName: nil,
            remainingDeckCount: 10
        )

        let signed = try signer.sign(state)
        let decoded = try signer.verifyAndDecode(signed)

        XCTAssertEqual(decoded, state)
    }

    func testHTTPSRequiredForNetworkingService() async {
        let service = URLSessionNetworkingService()
        let insecureURL = URL(string: "http://example.com/game")!

        do {
            try await service.post(event: .stay(playerID: UUID()), to: insecureURL)
            XCTFail("Expected insecure transport to be rejected")
        } catch let error as NetworkingError {
            XCTAssertEqual(error, .insecureTransportNotAllowed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}