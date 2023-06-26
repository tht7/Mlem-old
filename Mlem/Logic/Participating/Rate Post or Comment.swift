//
//  Rate Post or Comment.swift
//  Mlem
//
//  Created by David Bureš on 23.05.2023.
//

import Foundation

enum ScoringOperation: Int, Decodable {
    case upvote = 1
    case downvote = -1
    case resetVote = 0
}

enum RatingFailure: Error {
    case failedToPostScore
}

@MainActor
func ratePost(
    postId: Int,
    operation: ScoringOperation,
    account: SavedAccount,
    postTracker: PostTracker,
    appState: AppState
) async throws -> APIPostView {
    do {
        let request = CreatePostLikeRequest(
            account: account,
            postId: postId,
            score: operation
        )
#if !os(macOS) && !os(xrOS)
        AppConstants.hapticManager.notificationOccurred(.success)
#endif
        let response = try await APIClient().perform(request: request)
        postTracker.update(with: response.postView)
        return response.postView
    } catch {
#if !os(macOS) && !os(xrOS)
        AppConstants.hapticManager.notificationOccurred(.error)
#endif
        throw RatingFailure.failedToPostScore
    }
}

@MainActor
func rateComment(
    comment: APICommentView,
    operation: ScoringOperation,
    account: SavedAccount,
    commentTracker: CommentTracker,
    appState: AppState
) async throws -> HierarchicalComment? {
    do {
        let request = CreateCommentLikeRequest(
            account: account,
            commentId: comment.id,
            score: operation
        )
#if !os(macOS) && !os(xrOS)
        AppConstants.hapticManager.notificationOccurred(.success)
#endif
        let response = try await APIClient().perform(request: request)
        let updatedComment = commentTracker.comments.update(with: response.commentView)
        return updatedComment
    } catch let ratingOperationError {
#if !os(macOS) && !os(xrOS)
        AppConstants.hapticManager.notificationOccurred(.error)
#endif
        print("Failed while trying to score: \(ratingOperationError)")
        throw RatingFailure.failedToPostScore
    }
}
