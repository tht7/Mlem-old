//
//  App Constants.swift
//  Mlem
//
//  Created by David Bureš on 03.05.2023.
//

import Foundation
import KeychainAccess
#if !os(macOS)
import UIKit
#endif

struct AppConstants
{
    static let cacheSize = 500_000_000 // 500MiB in bytes
    static let urlCache: URLCache = URLCache(memoryCapacity: cacheSize, diskCapacity: cacheSize)
    static let webSocketSession: URLSession = URLSession(configuration: .default)
    static let urlSession: URLSession = URLSession(configuration: .default)

    // MARK: - Date parsing
    static let dateFormatter: DateFormatter = DateFormatter()
    static let relativeDateFormatter: RelativeDateTimeFormatter = RelativeDateTimeFormatter()

    // MARK: - Keychain
    static let keychain: Keychain = Keychain(service: "com.davidbures.Mlem-tht7")

    // MARK: - Files
    private static let applicationSupportDirectoryPath: URL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static let savedAccountsFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Saved Accounts", conformingTo: .json)
    static let savedAccountsPreferenceFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Saved Account Preferance", conformingTo: .json)
    static let filteredKeywordsFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Blocked Keywords", conformingTo: .json)
    static let favoriteCommunitiesFilePath: URL = applicationSupportDirectoryPath.appendingPathComponent("Favorite Communities", conformingTo: .json)

    #if os(iOS) && !os(xrOS)
    // MARK: - Haptics
    static let hapticManager: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
    #endif
    
    // MARK: - DragGesture thresholds
    static let longSwipeDragMin: CGFloat = 150;
    static let shortSwipeDragMin: CGFloat = 60;
}
