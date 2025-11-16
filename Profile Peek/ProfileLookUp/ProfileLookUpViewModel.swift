//
//  UserLookupViewModel.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ProfileLookupViewModel: ObservableObject {
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
            // Concurrently load posts for the found user
            if let uid = found.id {
                postsTask = Task { [weak self] in
                    guard let self else { return }
                    do {
                        let posts = try await self.service.fetchPosts(userId: uid)
                        await MainActor.run {
                            self.postsCache[uid] = posts
                        }
                    } catch {
                        
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

