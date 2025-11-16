//
//  UserLookupViewModel.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - MVVM ViewModel for Screen 1 (Search)
// Owns search input, loading/error state, and the found user.
// Also prefetches posts for the found user to improve Screen 2 responsiveness.
// Depends on UserServiceProtocol, injected for testability.

@MainActor
final class ProfileLookUpViewModel: ObservableObject {
    @Published var username: String = ""{
        didSet{
            if username == ""{
                user = nil
            }
        }
    }
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var user: User? = nil
    // Error handling
    @Published private(set) var errorMessage: String? = nil
    
    // Prefetched posts cache keyed by userId
    @Published private(set) var postsCache: [Int: [Post]] = [:]
    
    private let service: UserServiceProtocol
    private var searchTask: Task<Void, Never>? = nil
    private var postsTask: Task<Void, Never>? = nil
    
    init(service: UserServiceProtocol = UserService()) {
        self.service = service
    }
    
    func search() async {
        await fetchUser()
    }
    
    // Orchestrates the user search flow.
    // Resets state, calls service, animates in the found user, and prefetches posts.
    func fetchUser() async {
        errorMessage = nil
        isLoading = true
        user = nil
        postsTask?.cancel()
        do {
            let found = try await service.fetchUser(username: username)
            withAnimation {
                self.user = found
            }
            // Concurrently load posts for current user
            if let uid = found.id {
                postsTask = Task { [weak self] in
                    guard let self else { return }
                    do {
                        let posts = try await self.service.fetchPosts(userId: uid)
                        await MainActor.run {
                            self.postsCache[uid] = posts
                        }
                    } catch {
                        // Intentionally swallowed: prefetch failure should not block navigation.
                    }
                }
            }
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }
    
    func handleRetry() async{
        await fetchUser()
    }
}

