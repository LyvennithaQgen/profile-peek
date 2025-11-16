//
//  userDetailViewModel.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

import Combine
import SwiftUI
import Foundation
import CoreLocation

// MARK: - MVVM ViewModel for Screen 2 (Details/Posts)
// Exposes user-derived properties for the details tab and orchestrates post loading.
// Depends on UserServiceProtocol for data access (DI-friendly for unit tests).

@MainActor
final class ProfileLookUpDetailViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    private let service: UserServiceProtocol
    private let user: User
    
    init(user: User, service: UserServiceProtocol = UserService()) {
        self.user = user
        self.service = service
    }
    
    // Convenience initializer allows passing prefetched posts from Screen 1.
    convenience init(user: User, initialPosts: [Post]? = nil, service: UserServiceProtocol = UserService()) {
        self.init(user: user, service: service)
        if let initialPosts {
            self.posts = initialPosts
        }
    }
    
    // Not in use currently: If pull-to-refresh or explicit reload is added, call this.
    // Intentionally no-op if posts are already present (avoids duplicate fetches).
    func loadPosts() async {
        if !posts.isEmpty { return }
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await service.fetchPosts(userId: user.id ?? 0)
            self.posts = fetched
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
}

extension ProfileLookUpDetailViewModel {
    // Derived properties for the details tab (pure mapping from User).
    var userName: String {
        user.name ?? ""
    }
    var username: String {
        user.username ?? ""
    }
    var phone: String? {
        user.phone
    }
    var website: String? {
        user.website
    }
    var email: String? {
        user.email
    }
    var companyName: String? {
        user.company?.name
    }
    var userInfoHeader: String {
        "Details for \(user.name ?? "")"
    }
    
    var addressLine: String? {
        guard let a = user.address else { return nil }
        let parts = [a.suite, a.street, a.city, a.zipcode]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
    
    // Best-effort Apple Maps URL using lat/lng if present, otherwise address string.
    func mapsURL() -> URL? {
        if let latStr = user.address?.geo?.lat,
           let lngStr = user.address?.geo?.lng,
           let lat = Double(latStr), let lng = Double(lngStr) {
            let urlString = "http://maps.apple.com/?ll=\(lat),\(lng)&q=\(urlEncoded(user.name ?? "Location"))"
            return URL(string: urlString)
        }
        
        if let address = addressLine, !address.isEmpty {
            let encoded = urlEncoded(address)
            let urlString = "http://maps.apple.com/?q=\(encoded)"
            return URL(string: urlString)
        }
        
        return nil
    }
    
    // Derives an email address from username and website if email is absent.
    func vmUsernameToEmail() -> String? {
        let uname = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !uname.isEmpty else { return nil }
        
        var domain: String = "example.com"
        if let website, !website.isEmpty {
            let normalized = website.lowercased().hasPrefix("http://") || website.lowercased().hasPrefix("https://") ? website : "https://\(website)"
            if let comps = URL(string: normalized), let host = comps.host, !host.isEmpty {
                domain = host
            } else {
                let trimmed = website.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.contains("."), !trimmed.contains(" ") {
                    domain = trimmed
                }
            }
        }
        return "\(uname)@\(domain)"
    }
    
    // MARK: - Helpers
    private func urlEncoded(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
}

