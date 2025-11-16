//
//  Constants+String.swift
//  Profile Peek
//
//  Created by Lyvennitha on 16/11/25.
//

import Foundation

// Centralized strings for titles, messages, and accessibility identifiers.
// Keeps UI text consistent and facilitates testing.

enum Constants {
    
    enum Titles {
        static let appTitle = "User Lookup"
        static let userDetails = "User Details"
        static let userPosts = "User Posts"
    }
    
    enum Messages {
        static let searchPlaceholder = "Enter username (e.g., Bret)"
        static let searching = "Searching..."
        static let loadingPosts = "Loading posts..."
        static let noPosts = "No posts for this user."
        static let searchHint = "Type a username and hit the search button. Example: Bret"
        static let retry = "Retry"
    }
    
    enum AccessibilityIDs {
        enum UserLookup {
            static let usernameField = "userNameTextField"
            static let searchButton = "SearchButton"
            static let errorView = "errorView"
            static let userFoundLink = "userFoundLink"
        }
    }
}

