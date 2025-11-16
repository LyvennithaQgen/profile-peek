//
//  UserRepository.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

import Foundation

// MARK: - Services & UseCases
// AppURLs centralizes base URL and endpoint paths.
// The Service layer (UserService) is the app's repository/use-case facade
// that the ViewModels depend on (MVVM + Repository pattern).

enum AppURLs: String{
    case baseURL = "https://jsonplaceholder.typicode.com"
    case users = "/users"
    case posts = "/posts"
}

protocol UserServiceProtocol {
    func fetchUser(username: String) async throws -> User
    func fetchPosts(userId: Int) async throws -> [Post]
}

final class UserService: UserServiceProtocol {
    private let api: APIClientProtocol
    
    init(api: APIClientProtocol = APIClient()) {
        self.api = api
    }
    
    // Fetch all users and filter by username (case-insensitive contains).
    // Returns the first match or throws .notFound.
    func fetchUser(username: String) async throws -> User {
        guard let usersURL = URL(string: AppURLs.baseURL.rawValue + AppURLs.users.rawValue)
        else{
            throw NetworkError.invalidURL
        }
        let users: [User] = try await api.fetch(from: usersURL)
        guard let user = users.first(where: { $0.username?.lowercased().contains(username.lowercased()) ?? false }) else {
            throw NetworkError.notFound
        }
        return user
    }
    
    // Fetch posts for a specific user using a query item (?userId=).
    // URLComponents avoids manual string concatenation errors.
    func fetchPosts(userId: Int) async throws -> [Post] {
        guard let postsURL = URL(string: AppURLs.baseURL.rawValue + AppURLs.posts.rawValue)
        else{
            throw NetworkError.invalidURL
        }
        var comps = URLComponents(url: postsURL, resolvingAgainstBaseURL: true)!
        comps.queryItems = [URLQueryItem(name: "userId", value: "\(userId)")]
        guard let url = comps.url else { throw NetworkError.invalidResponse }
        return try await api.fetch(from: url)
    }
}

