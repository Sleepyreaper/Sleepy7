import Foundation

struct PurchaseVerificationRequest: Codable {
    let productID: String
    let originalTransactionID: String
    let transactionID: String
    let signedTransactionInfo: String
    let environment: String
}

struct PurchaseVerificationResponse: Codable {
    let isEntitled: Bool
    let environment: String?
    let revocationDate: String?
}

final class PurchaseVerificationClient {
    static var shared: PurchaseVerificationClient? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "IAPVerificationBaseURL") as? String,
              let url = URL(string: urlString),
              !urlString.isEmpty
        else {
            return nil
        }

        return PurchaseVerificationClient(baseURL: url)
    }

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func verify(request: PurchaseVerificationRequest) async throws -> PurchaseVerificationResponse {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent("/api/iap/verify"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 20
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.cannotParseResponse)
        }

        return try JSONDecoder().decode(PurchaseVerificationResponse.self, from: data)
    }
}