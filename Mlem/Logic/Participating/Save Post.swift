//
//  Save Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-19.
//

@MainActor
func sendSavePostRequest(account: SavedAccount,
              postId: Int,
              save: Bool,
              postTracker: PostTracker) async throws -> APIPostView {
    do {
        let request = SavePostRequest(account: account, postId: postId, save: save)
        
        #if !os(macOS) && !os(xrOS)
        AppConstants.hapticManager.notificationOccurred(.success)
        #endif
        let response = try await APIClient().perform(request: request)
        
        postTracker.update(with: response.postView)
        
        return response.postView
    }
    catch {
        #if !os(macOS) && !os(xrOS)
        AppConstants.hapticManager.notificationOccurred(.error)
        #endif
        throw RatingFailure.failedToPostScore
    }
}
