//
//  ProfileLookUpDetailView.swift
//  Profile Peek
//
//  Created by Lyvennitha on 17/11/25.
//

import SwiftUI

// MARK: - Screen 2 (Details/Posts) View
// MVVM: Binds to ProfileLookUpDetailViewModel (not shown) via @StateObject.
// Presents a segmented control with “User Details” and “User Posts” tabs.
// Details tab shows actionable rows (phone, email, address->Maps, website).
// Posts tab handles loading/error/empty states and renders a styled list.

struct ProfileLookUpDetailView: View {
    @StateObject private var vm: ProfileLookUpDetailViewModel
    @State private var selectedTab: Tab = .details
    @Environment(\.openURL) private var openURL
    
    enum Tab: String, CaseIterable {
        case details = "User Details"
        case posts = "User Posts"
    }
    
    init(user: User, initialPosts: [Post]? = nil) {
        _vm = StateObject(wrappedValue: ProfileLookUpDetailViewModel(user: user, initialPosts: initialPosts))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColors.primary.ignoresSafeArea()
            
            VStack(spacing: 12) {
                Picker("", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tabTitle(for: tab)).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .tint(.white)
                .padding(.horizontal)
                
                ZStack {
                    Color.white
                        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                        .ignoresSafeArea(edges: .bottom)
                    
                    Group {
                        switch selectedTab {
                        case .details:
                            detailsView
                        case .posts:
                            postsView
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.top, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationTitle(Constants.Titles.appTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            // Segmented control styling (UIKit appearance proxy).
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white
            ]
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black
            ]
            UISegmentedControl.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
            UISegmentedControl.appearance().backgroundColor = .clear
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.white
        }
    }
    
    private func tabTitle(for tab: Tab) -> String {
        switch tab {
        case .details: return Constants.Titles.userDetails
        case .posts: return Constants.Titles.userPosts
        }
    }
    
    private var detailsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader
                
                VStack(spacing: 12) {
                    if let phone = vm.phone, !phone.isEmpty {
                        infoRow(
                            icon: "phone.fill",
                            title: "Phone",
                            value: phone,
                            action: { if let url = URL(string: "tel:\(phone.filter { !$0.isWhitespace })") { openURL(url) } }
                        )
                    }
                    
                    if let email = vm.email, !email.isEmpty {
                        infoRow(
                            icon: "envelope.fill",
                            title: "Email",
                            value: email,
                            action: { if let url = URL(string: "mailto:\(email)") { openURL(url) } }
                        )
                    } else if let derived = vm.vmUsernameToEmail(), !derived.isEmpty {
                        infoRow(
                            icon: "envelope.fill",
                            title: "Email",
                            value: derived,
                            action: { if let url = URL(string: "mailto:\(derived)") { openURL(url) } }
                        )
                    }
                    
                    if let address = vm.addressLine, !address.isEmpty, let mapURL = vm.mapsURL() {
                        infoRow(
                            icon: "mappin.and.ellipse",
                            title: "Address",
                            value: address,
                            action: { openURL(mapURL) }
                        )
                    }
                   
                    
                    if let companyName = vm.companyName, !companyName.isEmpty {
                        infoRow(
                            icon: "building.2.fill",
                            title: "Company",
                            value: companyName,
                            action: nil
                        )
                    }
                    
                    if let website = vm.website, !website.isEmpty {
                        let normalized = normalizedWebsite(website)
                        infoRow(
                            icon: "globe",
                            title: "Website",
                            value: website,
                            action: { if let url = URL(string: normalized) { openURL(url) } }
                        )
                    }
                    
                   
                }
                .padding(.horizontal)
                
                Spacer(minLength: 0)
            }
            .padding(.bottom)
        }
    }
    
    private var profileHeader: some View {
        let name = vm.userName.isEmpty ? vm.username : vm.userName
        let initial = String(name.prefix(1)).uppercased()
        
        return VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 96, height: 96)
                Text(initial)
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.primary)
            }
            .padding(.top, 8)
            
            Text(vm.userName.isEmpty ? "Unknown" : vm.userName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if !vm.username.isEmpty {
                Text("@\(vm.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
    
    private func infoRow(icon: String, title: String, value: String, action: (() -> Void)?) -> some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .foregroundStyle(AppColors.primary)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
    
    private var postsView: some View {
        Group {
            if vm.isLoading {
                ProgressView(Constants.Messages.loadingPosts)
                    .padding()
                    .foregroundStyle(.secondary)
            } else if let error = vm.errorMessage {
                VStack(spacing: 8) {
                    Text(error).foregroundColor(.red)
                    Button(action: { Task { await vm.loadPosts() } }) {
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
                }
                .padding()
            } else if vm.posts.isEmpty {
                VStack {
                    Spacer()
                    Text(Constants.Messages.noPosts)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List(vm.posts) { post in
                    PostRow(post: post)
                        .padding(12)
                        .listRowSeparator(.hidden) // hide separators
                        .listRowInsets(EdgeInsets()) // allow card to control its own padding
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listSectionSeparator(.hidden)
                .scrollIndicators(.hidden)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // Helpers
    private func normalizedWebsite(_ website: String) -> String {
        if website.lowercased().hasPrefix("http://") || website.lowercased().hasPrefix("https://") {
            return website
        } else {
            return "https://\(website)"
        }
    }
}

