import Foundation
import Combine

enum GameEvent: Codable, Equatable, Sendable {
    case hit(playerID: UUID)
    case stay(playerID: UUID)
    case useFreeze(sourcePlayerID: UUID, targetPlayerID: UUID)
    case gameStateSync(SignedGameStatePayload)
}

enum NetworkingError: Error, Equatable {
    case insecureTransportNotAllowed
    case invalidHTTPResponse
}

protocol MatchClient: Sendable {
    func send(_ event: GameEvent) async throws
    func events() -> AsyncStream<GameEvent>
}

protocol NetworkingServiceProtocol: Sendable {
    func post(event: GameEvent, to endpoint: URL) async throws
    func publisher(for endpoint: URL) -> AnyPublisher<GameEvent, Error>
}

struct URLSessionNetworkingService: NetworkingServiceProtocol {
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func post(event: GameEvent, to endpoint: URL) async throws {
        try validateHTTPS(url: endpoint)

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(event)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NetworkingError.invalidHTTPResponse
        }
    }

    func publisher(for endpoint: URL) -> AnyPublisher<GameEvent, Error> {
        do {
            try validateHTTPS(url: endpoint)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.timeoutInterval = 30

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    throw NetworkingError.invalidHTTPResponse
                }
                return data
            }
            .decode(type: GameEvent.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    private func validateHTTPS(url: URL) throws {
        guard url.scheme?.lowercased() == "https" else {
            throw NetworkingError.insecureTransportNotAllowed
        }
    }
}

actor LocalPassAndPlayClient: MatchClient {
    private var continuations: [UUID: AsyncStream<GameEvent>.Continuation] = [:]

    func send(_ event: GameEvent) async throws {
        for continuation in continuations.values {
            continuation.yield(event)
        }
    }

    nonisolated func events() -> AsyncStream<GameEvent> {
        AsyncStream { continuation in
            let token = UUID()
            Task { await self.register(continuation, token: token) }
            continuation.onTermination = { _ in
                Task { await self.unregister(token: token) }
            }
        }
    }

    private func register(_ continuation: AsyncStream<GameEvent>.Continuation, token: UUID) {
        continuations[token] = continuation
    }

    private func unregister(token: UUID) {
        continuations[token] = nil
    }
}