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
    
    // New initializer that accepts optional initial posts
    convenience init(user: User, initialPosts: [Post]? = nil, service: UserServiceProtocol = UserService()) {
        self.init(user: user, service: service)
        if let initialPosts {
            self.posts = initialPosts
        }
    }
    
    // Not in use: : if pull to refresh required we can use it in Future
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
    
    // Address presentation
    var addressLine: String? {
        guard let a = user.address else { return nil }
        let parts = [a.suite, a.street, a.city, a.zipcode]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
    
    // Build an Apple Maps URL for either coordinates or a postal address
    func mapsURL() -> URL? {
        // Prefer coordinates if available
        if let latStr = user.address?.geo?.lat,
           let lngStr = user.address?.geo?.lng,
           let lat = Double(latStr), let lng = Double(lngStr) {
            // Apple Maps query for coordinates
            let urlString = "http://maps.apple.com/?ll=\(lat),\(lng)&q=\(urlEncoded(user.name ?? "Location"))"
            return URL(string: urlString)
        }
        
        // Otherwise use address string
        if let address = addressLine, !address.isEmpty {
            let encoded = urlEncoded(address)
            let urlString = "http://maps.apple.com/?q=\(encoded)"
            return URL(string: urlString)
        }
        
        return nil
    }
    
    // Derive an email from username and website if real email is unavailable.
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

