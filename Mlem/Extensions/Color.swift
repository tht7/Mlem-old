//
//  Color.swift
//  Mlem
//
//  Created by David Bureš on 26.03.2022.
//

import Foundation
import SwiftUI
import UIKit

extension Color
{
    // This is here to give me dynamic light/dark system colors for view backgrounds
    // Maybe add more colors down the line if needed?
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)
    
    // Interaction colors--redundant right now, but this will be nice if we want to change them later
    static let upvoteColor = Color.blue
    static let downvoteColor = Color.red
    static let saveColor = Color.green
    
    static let lightGray = Color(red: 0.8, green: 0.8, blue: 0.8)
    static let darkGray = Color(red: 0.2, green: 0.2, blue: 0.2)
}

public extension Color
{
    static func random(randomOpacity: Bool = false) -> Color
    {
        Color(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1),
            opacity: randomOpacity ? .random(in: 0 ... 1) : 1
        )
    }
}
