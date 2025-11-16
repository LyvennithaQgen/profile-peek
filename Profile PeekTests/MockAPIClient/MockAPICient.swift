//
//  MockAPICient.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

@testable import Profile_Peek
import Foundation

final class MockAPIClient: APIClientProtocol {
    var resultData: Data?
    var resultError: Error?
    
    func fetch<T>(from url: URL) async throws -> T where T : Decodable {
        if let e = resultError { throw e }
        guard let d = resultData else { throw NetworkError.decodingFailed }
        return try JSONDecoder().decode(T.self, from: d)
    }
}


final class MockAPIClientSuccess: APIClientProtocol {
    let data: Data
    init(data: Data) {
        self.data = data
    }
    
    func fetch<T>(from url: URL) async throws -> T where T : Decodable {
        return try JSONDecoder().decode(T.self, from: data)
    }
}

final class MockAPIClientFailure: APIClientProtocol {
    let error: Error
    init(error: Error) {
        self.error = error
    }
    
    func fetch<T>(from url: URL) async throws -> T where T : Decodable {
        throw error
    }
}
