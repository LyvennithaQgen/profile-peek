//
//  APIService.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

import Foundation

// Centralized error types for the networking layer.
// Conforms to LocalizedError to surface readable messages in UI.
enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case decodingFailed
    case notFound
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from server"
        case .decodingFailed: return "Failed to decode data"
        case .notFound: return "Not found"
        case .invalidURL: return "Not a valid URL"
        }
    }
}

// MARK: - Network Layer
// APIClientProtocol abstracts network fetching, enabling DI and mocking.
// APIClient is a simple generic client using URLSession + JSONDecoder.

protocol APIClientProtocol {
    func fetch<T: Decodable>(from url: URL) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try decoder.decode(T.self, from: data)
    }
}

