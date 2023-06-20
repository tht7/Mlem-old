//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

@main
struct MlemApp: App
{
    @AppStorage("hasUndergoneLegacyAccountDeletion_debug_3") var hasUndergoneLegaryAccountDeletion_debug: Bool = false
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified

    @StateObject var appState: AppState = .init()
    @StateObject var accountsTracker: SavedAccountTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()

    @StateObject var favoriteCommunitiesTracker: FavoriteCommunitiesTracker = .init()
    @StateObject var communitySearchResultsTracker: CommunitySearchResultsTracker = .init()

    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environmentObject(appState)
                .environmentObject(accountsTracker)
                .environmentObject(filtersTracker)
                .environmentObject(favoriteCommunitiesTracker)
                .environmentObject(communitySearchResultsTracker)
                .onChange(of: accountsTracker.savedAccounts)
                { newValue in
                    do
                    {
                        let encodedSavedAccounts: Data = try encodeForSaving(object: newValue)

                        do
                        {
                            try writeDataToFile(data: encodedSavedAccounts, fileURL: AppConstants.savedAccountsFilePath)
                        }
                        catch let writingError
                        {
                            print("Failed while saving data to file: \(writingError)")
                        }
                    }
                    catch let encodingError
                    {
                        print("Failed while encoding accounts to data: \(encodingError)")
                    }
                }
                .onChange(of: filtersTracker.filteredKeywords)
                { newValue in
                    print("Change detected in filtered keywords: \(newValue)")
                    do
                    {
                        let encodedFilteredKeywords: Data = try encodeForSaving(object: newValue)

                        print(encodedFilteredKeywords)
                        do
                        {
                            try writeDataToFile(data: encodedFilteredKeywords, fileURL: AppConstants.filteredKeywordsFilePath)
                        }
                        catch let writingError
                        {
                            print("Failed while saving data to file: \(writingError)")
                        }
                    }
                    catch let encodingError
                    {
                        print("Failed while encoding filters to data: \(encodingError)")
                    }
                }
                .onChange(of: favoriteCommunitiesTracker.favoriteCommunities)
                { newValue in
                    print("Change detected in favorited communities: \(newValue)")

                    do
                    {
                        let encodedFavoriteCommunities: Data = try encodeForSaving(object: newValue)

                        do
                        {
                            try writeDataToFile(data: encodedFavoriteCommunities, fileURL: AppConstants.favoriteCommunitiesFilePath)
                        }
                        catch let writingError
                        {
                            print("Failed while saving data to file: \(writingError)")
                        }
                    }
                    catch let encodingError
                    {
                        print("Failed while encoding favorited communities to data: \(encodingError)")
                    }
                }
                .onChange(of: lightOrDarkMode, perform: { value in
                    let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.windows.first?.overrideUserInterfaceStyle = value
                })
                .onAppear
                {
                    if FileManager.default.fileExists(atPath: AppConstants.savedAccountsFilePath.path)
                    {
                        print("Saved Accounts file exists, will attempt to load saved accounts")

                        do
                        {
                            let loadedUpAccounts = try decodeFromFile(fromURL: AppConstants.savedAccountsFilePath, whatToDecode: .accounts) as! [SavedAccount]

                            // MARK: - Associate the accounts with their secret credentials

                            if !loadedUpAccounts.isEmpty
                            {
                                var loadedUpAccountTracker: [SavedAccount] = .init()

                                for account in loadedUpAccounts
                                {
                                    loadedUpAccountTracker.append(SavedAccount(id: account.id, instanceLink: account.instanceLink, accessToken: AppConstants.keychain["\(account.id)_accessToken"]!, username: account.username))
                                }

                                accountsTracker.savedAccounts = loadedUpAccountTracker
                            }
                        }
                        catch let savedAccountDecodingError
                        {
                            print("Failed while decoding saved accounts: \(savedAccountDecodingError)")
                        }
                    }
                    else
                    {
                        print("Saved Accounts file does not exist, will try to create it")

                        do
                        {
                            try createEmptyFile(at: AppConstants.savedAccountsFilePath)
                        }
                        catch let emptyFileCreationError
                        {
                            print("Failed while creating an empty file: \(emptyFileCreationError)")
                        }
                    }

                    if FileManager.default.fileExists(atPath: AppConstants.filteredKeywordsFilePath.path)
                    {
                        print("Filtered keywords file exists, will attempt to load blocked keywords")
                        do
                        {
                            filtersTracker.filteredKeywords = try decodeFromFile(fromURL: AppConstants.filteredKeywordsFilePath, whatToDecode: .filteredKeywords) as! [String]
                        }
                        catch let savedKeywordsDecodingError
                        {
                            print("Failed while decoding saved filtered keywords: \(savedKeywordsDecodingError)")
                        }
                    }
                    else
                    {
                        print("Filtered keywords file does not exist, will try to create it")

                        do
                        {
                            try createEmptyFile(at: AppConstants.filteredKeywordsFilePath)
                        }
                        catch let emptyFileCreationError
                        {
                            print("Failed while creating an empty file: \(emptyFileCreationError)")
                        }
                    }

                    if FileManager.default.fileExists(atPath: AppConstants.favoriteCommunitiesFilePath.path)
                    {
                        print("Favorite communities file exists, will attempt to load favorite communities")
                        do
                        {
                            favoriteCommunitiesTracker.favoriteCommunities = try decodeFromFile(fromURL: AppConstants.favoriteCommunitiesFilePath, whatToDecode: .favoriteCommunities) as! [FavoriteCommunity]
                        }
                        catch let favoriteCommunitiesDecodingError
                        {
                            print("Failed while decoding favorite communities: \(favoriteCommunitiesDecodingError)")
                        }
                    }
                    else
                    {
                        print("Favorite communities file does not exist, will try to create it")

                        do
                        {
                            try createEmptyFile(at: AppConstants.favoriteCommunitiesFilePath)
                        }
                        catch let emptyFileCreationError
                        {
                            print("Failed while creating empty file: \(emptyFileCreationError)")
                        }
                    }
                    
                    // set app theme to user preference
                    let windowScene =  UIApplication.shared.connectedScenes.first as? UIWindowScene
                    windowScene?.windows.first?.overrideUserInterfaceStyle = lightOrDarkMode
                }
        }
    }
}
