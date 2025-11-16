//
//  ProfilePeekPostView.swift
//  Profile Peek
//
//  Created by Lyvennitha on 15/11/25.
//

import SwiftUI

struct PostRowView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title ?? "")
                .font(.headline)
                .foregroundStyle(AppColors.primary)
                .lineLimit(2)
            
            Text(post.body ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
    }
}

