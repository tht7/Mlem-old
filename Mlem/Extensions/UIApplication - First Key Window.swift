//
//  UIApplication - First Key Window.swift
//  Mlem
//
//  Created by David Bureš on 18.05.2023.
//

import Foundation
#if os(macOS)
import AppKit

extension NSApplication {
    var firstKeyWindow: NSWindow?
    {
        return NSApplication.shared.keyWindow
    }
}
#else
import UIKit

extension UIApplication
{
    var firstKeyWindow: UIWindow?
    {
        return UIApplication.shared.connectedScenes
            .compactMap{ $0 as? UIWindowScene }
            .filter{ $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
#endif
