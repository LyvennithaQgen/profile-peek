//
//  Readme.swift
//  Profile Peek
//
//  Created by Lyvennitha on 17/11/25.
//
//  System Design, Architecture and Requirements Checklist
//
//  Overview
//  --------
//  Profile Peek is an iOS app for user lookup that displays a user's details and posts.
//  The app uses SwiftUI for UI, Swift Concurrency (async/await) for networking, and a layered
//  architecture that follows MVVM at the presentation layer, with a Service/Repository abstraction
//  for data access and a dedicated networking client.
//
//  Layers and Responsibilities
//  ---------------------------
//  - Models (Data/Domain):
//      * User, Address, Geo, Company, Post (Codable, Identifiable where needed).
//        These mirror the JSONPlaceholder schema and are used across layers.
//  - Networking Layer:
//      * APIClientProtocol: generic async fetch<T: Decodable>(from: URL) API.
//      * APIClient: concrete implementation using URLSession.shared and JSONDecoder.
//      * NetworkError: centralized error types with user-readable descriptions.
//  - Service/Repository Layer:
//      * AppURLs: centralized base URL and endpoints (/users, /posts).
//      * UserServiceProtocol: contract for fetching a user by username and a user’s posts.
//      * UserService: builds URLs, calls APIClient, maps/filter results (e.g., username search).
//        Uses URLComponents for safe query construction.
//  - Presentation Layer (MVVM + SwiftUI):
//      * Screen 1: ProfileLookUpView + ProfileLookUpViewModel.
//          - Accepts username input, invokes UserService.fetchUser, prefetches posts,
//            exposes state (isLoading, user, errorMessage, postsCache) for the view.
//      * Screen 2: ProfileLookUpDetailView + ProfileLookUpDetailViewModel.
//          - Renders a segmented control with “User Details” and “User Posts” tabs.
//          - Details tab shows user info and actionable rows (phone, email, address, website).
//          - Posts tab loads posts via the detail VM and renders loading/empty/error states.
//
//  Data Flow
//  ---------
//  1) User types a username in Screen 1 and triggers search.
//  2) ProfileLookUpViewModel calls UserService.fetchUser(username:):
//     - Builds users URL (AppURLs.baseURL + /users).
//     - Fetches [User] via APIClient, decodes, filters by case-insensitive contains on username.
//  3) On success, Screen 1 navigates to Screen 2 with the selected User with prefetched posts.
//  4) Screen 2’s ViewModel loads posts when needed via UserService.fetchPosts(userId:):
//     - Builds /posts?userId=... using URLComponents, fetches and decodes [Post].
//  5) SwiftUI reacts to published state changes and updates the UI.
//
//  Design Pattern
//  --------------
//  - MVVM at the UI layer: ViewModels own state and business logic; Views are declarative and bind to state.
//  - Service/Repository abstraction: ViewModels depend on protocols (UserServiceProtocol), enabling testability.
//  - Dependency Injection: Concrete APIClient and UserService are injected, allowing mock clients in tests.
//
//  Concurrency and Error Handling
//  ------------------------------
//  - Async/await is used for network calls and view model operations.
//  - NetworkError enumerates common errors with localized descriptions.
//  - URL building avoids force-unwraps and uses guards and URLComponents for safety.
//  - View models expose user-friendly errorMessage and loading flags for UI feedback.
//
//  UI/UX Highlights
//  ----------------
//  - Preferred Native Liquid Class Theme
//  - Modern SwiftUI cards and segmented tabs.
//  - Actionable rows: tap to call, email, open Maps, or open website.
//  - Posts list with loading, empty, and retry-on-error states.
//  - Styling centralized via AppColors and reusable components (RoundedCorner, PostRow, UserCardView).
//
//  Testing
//  -------
//  - Unit Tests (XCTest):
//      * Tests cover ProfileLookUpViewModel and ProfileLookUpDetailViewModel (posts loading).
//      * Mock API clients implement APIClientProtocol to simulate success/failure/empty cases.
//  - Functional/UI Tests (XCTest UI):
//      * UITest target exists (Profile_PeekUITests). Add end-to-end scenarios:
//          - Enter username, verify navigation to details screen.
//          - Switch to “User Posts”, verify loading and posts appear.
//          - Simulate network error, verify error message and retry behavior.
//          - Empty posts state verification.
//
//  Assumptions
//  -----------
//  - Username matching uses case-insensitive contains for a forgiving search experience.
//  - JSONPlaceholder is the data source; user IDs are unique and stable.
//  - Posts are loaded on demand in the detail screen; Screen 1 may prefetch for responsiveness.
//  - Basic theming via Color assets (AppColors.primary) and Constants for strings.
//
//  Potential Improvements
//  ----------------------
//  - Add caching (in-memory or URLCache) for users and posts.
//  - Switch to exact username matching if product requires strict lookup.
//  - Introduce pagination if posts can be large.
//  - Add Swift Testing (@Test/#expect) alongside XCTest.
//  - Add structured logging and analytics.
//  - Improve accessibility labels/hints for all interactive elements.
//
//  Requirements Checklist
//  ----------------------
//  1) iOS app for User Lookup: YES (SwiftUI-based).
//  2) Users and Posts APIs: YES (AppURLs + UserService implement /users and /posts?userId=).
//  3) Screen 1 search loads Screen 2: YES (ProfileLookUpView + ViewModel + NavigationLink).
//  4) Screen 2 tabs for “User Details” and “User Posts”: YES (ProfileLookUpDetailView).
//  5) Suitable design pattern: YES (MVVM + Service/Repository + DI).
//  6) Unit Tests: YES (provided tests cover search and posts loading with mocks).
//  7) Functional Tests: PARTIAL (UITest target present; add concrete scenarios to fully satisfy).
//  8) Frameworks of choice: YES (SwiftUI, URLSession, XCTest, async/await).
//  9) UI improvements: YES (enhanced visuals, actionable detail rows, states).
// 10) Assumptions: YES (documented above).
//
