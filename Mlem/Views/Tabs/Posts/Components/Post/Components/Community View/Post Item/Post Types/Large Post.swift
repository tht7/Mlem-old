//
//  Large Post Preview.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import CachedAsyncImage
import SwiftUI

import Foundation

struct LargePost: View {
    // constants
    private let spacing: CGFloat = 10 // constant for readability, ease of modification
    
    // local state
    @State var showNsfwFilterToggle: Bool  //  = true // true when should blur
    
    // global state
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    // parameters
    let postView: APIPostView
    let account: SavedAccount
    let isExpanded: Bool
    let voteOnPost: (ScoringOperation) async -> Void
    
    // initializer--used so we can set showNsfwFilterToggle to false when expanded or true when not
    init(postView: APIPostView, account: SavedAccount, isExpanded: Bool, voteOnPost: @escaping (ScoringOperation) async -> Void) {
        self.postView = postView
        self.account = account
        self.isExpanded = isExpanded
        self.voteOnPost = voteOnPost
        _showNsfwFilterToggle = .init(initialValue: !isExpanded)
    }
    
    // computed properties
    // if NSFW, blur iff shouldBlurNsfw and enableBlur and in feed
    var showNsfwFilter: Bool { postView.post.nsfw ? shouldBlurNsfw && showNsfwFilterToggle : false }
    
    var body: some View {
        VStack(spacing: spacing) {
            // header--community/poster/ellipsis menu
            PostHeader(postView: postView, account: account)
                .padding(.bottom, -2) // negative padding to crunch header and title together just a wee bit
            
            // post title
            Text(postView.post.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // post body
            switch postView.postType {
            case .image(let url):
                imagePreview(url: url)
                postBodyView
            case .link:
                WebsiteIconComplex(post: postView.post)
            case .text(let postBody):
                // text posts need a little less space between title and body to look right, go figure
                postBodyView
                    .padding(.top, postBody.isEmpty ? nil : -2)
            case .titleOnly:
                EmptyView()
            }
            
            PostInteractionBar(postView: postView, account: account, compact: false, voteOnPost: voteOnPost)
        }
        .padding(.vertical, spacing)
        .padding(.horizontal, spacing)
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    var postBodyView: some View {
        if let bodyText = postView.post.body, !bodyText.isEmpty {
            if isExpanded {
                MarkdownView(text: bodyText)
                    .font(.subheadline)
            } else {
                MarkdownView(text: bodyText.components(separatedBy: .newlines).joined())
                    .lineLimit(8)
                    .font(.subheadline)
            }
        }
    }
    
    func imagePreview(url: URL) -> some View {
        ZStack {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .scaledToFill()
                    .blur(radius: showNsfwFilter ? 30 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 1))
            } placeholder: {
                ProgressView()
            }
            
            if showNsfwFilter {
                VStack {
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .font(.largeTitle)
                    Text("NSFW")
                        .fontWeight(.black)
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 4)
                    .foregroundColor(.systemBackground))
                .onTapGesture {
                    showNsfwFilterToggle.toggle()
                }
            }
            else if postView.post.nsfw && shouldBlurNsfw {
                // stacks are here to align image to top left of ZStack
                // TODO: less janky way to do this?
                HStack {
                    VStack {
                        Image(systemName: "eye.slash")
                            .padding(4)
                            .frame(alignment: .topLeading)
                            .background(RoundedRectangle(cornerRadius: 4)
                                .foregroundColor(.systemBackground))
                            .onTapGesture {
                                showNsfwFilterToggle.toggle()
                            }
                            .padding(4)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}
