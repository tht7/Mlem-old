//
//  Compact Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-11.
//

import CachedAsyncImage
import Foundation
import SwiftUI

struct CompactPost: View {
    // app storage
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 8 // constant for readability, ease of modification
    
    // arguments
    let postView: APIPostView
    let account: SavedAccount
    let voteOnPost: (ScoringOperation) async -> Void
    
    // computed
    var usernameColor: Color {
        if postView.creator.admin {
            return .red
        }
        if postView.creator.botAccount {
            return .indigo
        }
        
        return .secondary
    }
    
    var showNsfwFilter: Bool { postView.post.nsfw && shouldBlurNsfw }
    
    var body: some View {
        VStack(spacing: spacing) {
            HStack(alignment: .top) {
                thumbnailImage
                
                VStack(spacing: 2) {
                    Text(postView.post.name)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.trailing)
                    
                    HStack(spacing: 4) {
                        // stickied
                        if postView.post.featuredLocal { StickiedTag(compact: true) }
                        if postView.post.nsfw { NSFWTag(compact: true) }
                        
                        // community name
                        NavigationLink(destination: CommunityView(account: account, community: postView.community, feedType: .all)) {
                            Text(postView.community.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        Text("by")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        // poster
                        NavigationLink(destination: UserView(userID: postView.creator.id, account: account)) {
                            Text(postView.creator.name)
                                .font(.caption)
                                .italic()
                                .foregroundColor(usernameColor)
                        }
                        
                        Spacer()
                    }
                }
                
            }
            PostInteractionBar(postView: postView, account: account, compact: true, voteOnPost: voteOnPost)
        }
        .padding(spacing)
        .buttonStyle(EmptyButtonStyle())
    }
    
    @ViewBuilder
    private var thumbnailImage: some View {
        Group {
            switch postView.postType {
            case .image(let url):
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: showNsfwFilter ? 8 : 0) // blur nsfw
                } placeholder: {
                    ProgressView()
                }
            case .link(let url):
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: showNsfwFilter ? 8 : 0) // blur nsfw
                } placeholder: {
                    Image(systemName: "safari")
                }
            case .text:
                Image(systemName: "text.book.closed")
            case .titleOnly:
                Image(systemName: "character.bubble")
            }
        }
        .foregroundColor(.secondary)
        .font(.title)
        .frame(width: thumbnailSize, height: thumbnailSize)
        .adaptiveBackgroundColor(light: .lightGray, dark: .darkGray)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(.secondary, lineWidth: 1))
    }
}
