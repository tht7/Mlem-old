//
//  Download UIImage from URL.swift
//  Mlem
//
//  Created by David Bureš on 06.06.2023.
//

import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
func downloadUIImageFromURL(_ url: URL) async -> NSImage? {
    let session: URLSession = URLSession(configuration: .default)
    
    do
    {
        let (data, _) = try await session.data(from: url)
        return NSImage(data: data)
    }
    catch
    {
        return nil
    }
}
#else
func downloadUIImageFromURL(_ url: URL) async -> UIImage? {
    let session: URLSession = URLSession(configuration: .default)
    
    do
    {
        let (data, _) = try await session.data(from: url)
        return UIImage(data: data)
    }
    catch
    {
        return nil
    }
}
#endif
