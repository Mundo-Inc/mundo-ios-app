//
//  Fonts.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 22.09.2023.
//

import SwiftUI

extension Font.TextStyle {
    var size: CGFloat {
        return switch self {
        case .largeTitle:
            34
        case .title:
            28
        case .title2:
            22
        case .title3:
            20
        case .headline:
            17
        case .subheadline:
            14
        case .body:
            16
        case .callout:
            15
        case .footnote:
            13
        case .caption:
            12
        case .caption2:
            11
        case .extraLargeTitle:
            32
        case .extraLargeTitle2:
            26
        @unknown default:
            14
        }
    }
}
