//
//  Post Tracker.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation

@MainActor
class PostTracker: ObservableObject {
    
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var posts: [APIPostView] = .init()
    
    private var page: Int = 1
    private var ids: Set<Int> = .init()
    
    /// A method to request the tracker loads the next page of posts
    /// - Parameters:
    ///   - account: The `SavedAccount` for the logged in user
    ///   - communityId: An optional `Int` if you are retrieving posts for a specific community
    ///   - sort: The sorting type for the feed
    ///   - type: The type of feed the tracker should load
    func loadNextPage(account: SavedAccount, communityId: Int?, sort: SortingOptions?, type: FeedType) async throws {
        defer { isLoading = false }
        isLoading = true
        
        let request = GetPostsRequest(
            account: account,
            communityId: communityId,
            page: page,
            sort: sort,
            type: type
        )
        
        let response = try await APIClient().perform(request: request)
        
        guard !response.posts.isEmpty else {
            return
        }
        
        add(response.posts)
        page += 1
    }
    
    /// A method to add new posts into the tracker, duplicate posts will be rejected
    /// - Parameter newPosts: The array of `APIPostView` you wish to add
    func add(_ newPosts: [APIPostView]) {
        let accepted = newPosts.filter { ids.insert($0.id).inserted }
        posts.append(contentsOf: accepted)
    }
    
    /// A method to add a post to the start of the current list of posts
    /// - Parameter newPost: The `APIPostView` you wish to add
    func prepend(_ newPost: APIPostView) {
        guard ids.insert(newPost.id).inserted else {
            return
        }
        
        posts.prepend(newPost)
    }
    
    /// A method to supply an updated post to the tracker
    ///  - Note: If the `id` of the post is not already in the tracker the `updatedPost` will be discarded
    /// - Parameter updatedPost: An updated `APIPostView`
    func update(with updatedPost: APIPostView) {
        guard let index = posts.firstIndex(where: { $0.post.id == updatedPost.id }) else {
            return
        }
        
        posts[index] = updatedPost
    }
    
    /// A method to reset the tracker to it's initial state
    func reset() {
        ids = .init()
        page = 1
        posts = .init()
    }
}
