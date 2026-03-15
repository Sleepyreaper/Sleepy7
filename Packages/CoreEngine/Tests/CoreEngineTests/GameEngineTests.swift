import XCTest
@testable import CoreEngine

final class GameEngineTests: XCTestCase {
    func testDeterministicTransitionsWithSeed() async {
        let e1 = GameEngine(playerCount: 2, seed: 7)
        let e2 = GameEngine(playerCount: 2, seed: 7)

        await e1.handle(action: .hit)
        await e2.handle(action: .hit)
        await e1.handle(action: .stay)
        await e2.handle(action: .stay)

        let s1 = await e1.snapshot()
        let s2 = await e2.snapshot()
        XCTAssertEqual(s1, s2)
    }

    func testRoundAdvances() async {
        let engine = GameEngine(playerCount: 2, seed: 1)
        let start = await engine.snapshot()
        await engine.startNewRound()
        let next = await engine.snapshot()
        XCTAssertEqual(start.roundNumber + 1, next.roundNumber)
    }
}