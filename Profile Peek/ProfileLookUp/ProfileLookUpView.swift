//
//  ProfileLookUpView.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

import SwiftUI
import SwiftData

// MARK: - Screen 1 (Search) View
// MVVM: Binds to ProfileLookUpViewModel via @StateObject.
// Captures username input, triggers search, shows loading/error,
// and on success presents a NavigationLink to the detail screen.
// Prefetched posts from the VM are passed into the detail view for responsiveness.

struct ProfileLookUpView: View {
    
    @StateObject private var vm = ProfileLookUpViewModel()
    @FocusState private var isUsernameFocused: Bool
        
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // App background
                AppColors.primary.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack {
                        TextField(Constants.Messages.searchPlaceholder, text: $vm.username)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityIdentifier(Constants.AccessibilityIDs.UserLookup.usernameField)
                            .disableAutocorrection(true)
                            .focused($isUsernameFocused)
                        
                        Button(action: { 
                            isUsernameFocused = false
                            Task { await vm.search() } 
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding(8)
                                .foregroundStyle(Color.white)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier(Constants.AccessibilityIDs.UserLookup.searchButton)
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    
                    ZStack {
                        Color.white
                            .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                            .ignoresSafeArea(edges: .bottom)
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                if vm.isLoading {
                                    ProgressView(Constants.Messages.searching)
                                        .padding()
                                }
                                
                                if let error = vm.errorMessage {
                                    VStack(spacing: 8) {
                                        Spacer()
                                        Text(error)
                                            .foregroundColor(.secondary)
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                        // Retry on API failure
                                        Button(action: { Task { await vm.search() } }) {
                                            Text(Constants.Messages.retry)
                                                .font(.headline)
                                                .foregroundStyle(Color.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                        .fill(AppColors.primary)
                                                )
                                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                        }
                                        .buttonStyle(.plain)
                                        .padding()
                                    }
                                    .padding()
                                    .accessibilityIdentifier(Constants.AccessibilityIDs.UserLookup.errorView)
                                }
                                
                                if let user = vm.user {
                                    // Navigation to Screen 2 (Details/Posts).
                                    // Pass prefetched posts when available.
                                    NavigationLink(destination: {
                                        let initialPosts = vm.postsCache[user.id ?? -1]
                                        ProfileLookUpDetailView(user: user, initialPosts: initialPosts)
                                    }) {
                                        UserCardView(user: user)
                                            .padding(.horizontal)
                                    }
                                    .accessibilityIdentifier(Constants.AccessibilityIDs.UserLookup.userFoundLink)
                                } else if !vm.isLoading && vm.errorMessage == nil {
                                    VStack {
                                        Spacer(minLength: 80)
                                        Text(Constants.Messages.searchHint)
                                            .foregroundStyle(Color.secondary)
                                            .multilineTextAlignment(.center)
                                        Spacer(minLength: 0)
                                    }
                                    .padding()
                                }
                                
                                Spacer(minLength: 0)
                            }
                            .padding(.top, 16)
                        }
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                }
            }
            .navigationTitle(Constants.Titles.appTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
}

#Preview {
    ProfileLookUpView()
}

