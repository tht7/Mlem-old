//
//  Share Sheet.swift
//  Mlem
//
//  Created by David Bureš on 05.04.2022.
//

import SwiftUI

func showShareSheet(URLtoShare: URL)
{
    #if os(macOS)
    let service = NSSharingService.sharingServices(forItems: [URLtoShare])
    service[0].perform(withItems: [URLtoShare])
    #else
    let activityVC = UIActivityViewController(activityItems: [URLtoShare], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    #endif
}
