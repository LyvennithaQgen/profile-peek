//
//  ProfilePeekUserCardView.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

import SwiftUI

// Reusable card summarizing a user for the search results/navigation.
// Pure UI component with minimal presentation logic (initial letter, email username extraction).

struct UserCardView: View {
    let user: User
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay(Text(String((user.name ?? "").prefix(1))).font(.headline).foregroundStyle(AppColors.primary))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(user.name ?? "")
                    .font(.headline)
                    .foregroundStyle(AppColors.primary)
                if let email = user.email?.split(separator: "@").first {
                    Text(String(email))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text(user.email ?? "").font(.subheadline).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
        .shadow(radius: 1)
    }
}

