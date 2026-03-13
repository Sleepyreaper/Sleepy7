import Foundation
import AuthenticationServices
import Security

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case encodingError
    case unauthorized
    case missingToken
}

struct SubmitScoreRequest: Codable {
    let leaderboardId: String
    let mode: String
    let scoreValue: Int
}

struct LeaderboardEntry: Codable, Identifiable {
    var id: String { "\(playerId)-\(achievedUtc)" }
    let playerId: String
    let displayName: String
    let scoreValue: Int
    let achievedUtc: String
}

struct LeaderboardResponse: Codable {
    let mode: String
    let leaderboardId: String
    let entries: [LeaderboardEntry]
}

struct RemoteConfigResponse: Codable {
    let id: String
    let adFrequency: Int?
    let featureFlags: [String: Bool]?
}

protocol TokenProvider {
    func getAccessToken() async throws -> String
}

final class KeychainTokenProvider: TokenProvider {
    private let service = "com.sleepy7.auth"
    private let account = "b2c_access_token"

    func getAccessToken() async throws -> String {
        guard let data = readTokenData(), let token = String(data: data, encoding: .utf8), !token.isEmpty else {
            throw APIError.missingToken
        }
        return token
    }

    func saveAccessToken(_ token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)

        let attrs: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemAdd(attrs as CFDictionary, nil)
    }

    private func readTokenData() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: TokenProvider

    init(
        baseURL: URL = URL(string: "https://example.azurefd.net/api")!,
        session: URLSession = .shared,
        tokenProvider: TokenProvider = KeychainTokenProvider()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenProvider = tokenProvider
    }

    private func authorizedRequest(url: URL, method: String) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        let token = try await tokenProvider.getAccessToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func submitScore(_ requestPayload: SubmitScoreRequest) async throws {
        let url = baseURL.appendingPathComponent("score")
        var request = try await authorizedRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(requestPayload)
        } catch {
            throw APIError.encodingError
        }

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if http.statusCode == 401 { throw APIError.unauthorized }
        guard (200...299).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }
    }

    func getLeaderboard(mode: String, leaderboardId: String = "global", limit: Int = 20) async throws -> LeaderboardResponse {
        let url = baseURL.appendingPathComponent("leaderboard")
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "mode", value: mode),
            URLQueryItem(name: "leaderboardId", value: leaderboardId),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        guard let finalURL = components.url else { throw APIError.invalidURL }

        let request = try await authorizedRequest(url: finalURL, method: "GET")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if http.statusCode == 401 { throw APIError.unauthorized }
        guard (200...299).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }

        do {
            return try JSONDecoder().decode(LeaderboardResponse.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }

    func getConfig() async throws -> RemoteConfigResponse {
        let url = baseURL.appendingPathComponent("config")
        let request = try await authorizedRequest(url: url, method: "GET")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if http.statusCode == 401 { throw APIError.unauthorized }
        guard (200...299).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }

        do {
            return try JSONDecoder().decode(RemoteConfigResponse.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}