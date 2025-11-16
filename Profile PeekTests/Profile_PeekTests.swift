//
//  Profile_PeekTests.swift
//  Profile PeekTests
//
//  Created by Lyvennitha on 15/11/25.
//

import XCTest
@testable import Profile_Peek

// MARK: - Unit Tests Overview
// Tests cover MVVM behavior using mock API clients (DI via protocols).
// Scenarios: user found, successful search, not found, service failure, posts loading success.

final class Profile_PeekTests: XCTestCase {

    override func setUpWithError() throws {
        // Set up per-test if needed.
    }

    override func tearDownWithError() throws {
        // Tear down per-test if needed.
    }

    func testExample() throws {
        // Template test.
    }

    func testPerformanceExample() throws {
        measure {
            // Measure critical paths if needed.
        }
    }
    
    @MainActor
    func testSearchUserFound() async throws {
        // prepare mock user JSON
        let mockUser = User(id: 1, name: "Test User", username: "testuser", email: "test@example.com", address: nil, phone: nil, website: nil, company: nil)
        let data = try JSONEncoder().encode([mockUser])
        
        let mockApi = MockAPIClient()
        mockApi.resultData = data
        let service = UserService(api: mockApi)
        
        // Create the view model on the Main Actor
        let vm = ProfileLookUpViewModel(service: service)
        
        // Mutate and call methods on the Main Actor
        await MainActor.run {
            vm.username = "testuser"
        }
        await vm.search()
        
        // Read isolated properties on the Main Actor into local values
        let fetchedUser: User? = await MainActor.run {
            vm.user
        }
        
        // Assert on local (nonisolated) copies
        XCTAssertNotNil(fetchedUser)
        XCTAssertEqual(fetchedUser?.id, 1)
    }
    
    
    @MainActor
    func testSuccessfulSearch() async throws {
        // prepare mock users array
        let user = User(id: 1, name: "Leanne Graham", username: "Bret", email: "Sincere@april.biz", address: Address(street: "S", suite: "A", city: "C", zipcode: "Z", geo: Geo(lat: "-37.3", lng: "81.1")), phone: "1-770-736-8031 x56442", website: "hildegard.org", company: Company(name: "Romaguera-Crona", catchPhrase: "Multi-layered client-server neural-net", bs: "harness real-time e-markets"))
        let data = try JSONEncoder().encode([user])
        let mockApi = MockAPIClientSuccess(data: data)
        let service = UserService(api: mockApi)
        let vm = ProfileLookUpViewModel(service: service)
        vm.username = "Bret"
        
        await vm.search()
        
        XCTAssertNotNil(vm.user)
        XCTAssertEqual(vm.user?.id, 1)
    }
    
    @MainActor
    func testSearchNotFound() async throws {
        let data = try JSONEncoder().encode([User]())
        let mockApi = MockAPIClientSuccess(data: data)
        let service = UserService(api: mockApi)
        let vm = ProfileLookUpViewModel(service: service)
        vm.username = "unknown"
        
        await vm.search()
        
        XCTAssertNil(vm.user)
        XCTAssertNotNil(vm.errorMessage)
    }

    @MainActor
    func testServiceFailure() async throws {
        let mockApi = MockAPIClientFailure(error: NetworkError.invalidResponse)
        let service = UserService(api: mockApi)
        let vm = ProfileLookUpViewModel(service: service)
        vm.username = "Bret"
        
        await vm.search()
        
        XCTAssertNil(vm.user)
        XCTAssertNotNil(vm.errorMessage)
    }


}

final class UserDetailViewModelTests: XCTestCase {
    
    @MainActor
    func testLoadPostsSuccess() async throws {
        let post = Post(userId: 1, id: 1, title: "t", body: "b")
        let data = try JSONEncoder().encode([post])
        let mockApi = MockAPIClientSuccess(data: data)
        let service = UserService(api: mockApi)
        let user = User(id: 1, name: "Leanne", username: "Bret", email: "e", address: Address(street: "S", suite: "A", city: "C", zipcode: "Z", geo: Geo(lat: "-37", lng: "81")), phone: "p", website: "w", company: Company(name: "c", catchPhrase: "cp", bs: "bs"))
        let vm = ProfileLookUpDetailViewModel(user: user, service: service)
        
        await vm.loadPosts()
        
        XCTAssertEqual(vm.posts.count, 1)
        XCTAssertEqual(vm.posts.first?.id, 1)
    }
}

