//
//  ColorExtensions.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation
import SwiftUI

extension Color {
    enum ThemeColors: String {
        case background = "Background"
        case primary = "Primary"
        case border = "Border"
    }
    
    static let themeBG = Color(ThemeColors.background.rawValue)
    static let themePrimary = Color(ThemeColors.primary.rawValue)
    static let themeBorder = Color(ThemeColors.border.rawValue)
}
