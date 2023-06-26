//
//  Save Comment.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-21.
//

import Foundation

@MainActor
func sendSaveCommentRequest(account: SavedAccount,
              commentId: Int,
              save: Bool,
              commentTracker: CommentTracker) async throws {
    do {
        let request = SaveCommentRequest(account: account, commentId: commentId, save: save)
        #if !os(macOS) && !os(xrOS)
        AppConstants.hapticManager.notificationOccurred(.success)
        #endif
        
        let response = try await APIClient().perform(request: request)
        
        commentTracker.comments.update(with: response.commentView)
    }
    catch {
        print(error)
#if !os(macOS) && !os(xrOS)
        AppConstants.hapticManager.notificationOccurred(.error)
        #endif
        throw SavingFailure.failedToSaveComment
    }
}
