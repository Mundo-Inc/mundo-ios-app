//
//  Fonts.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 22.09.2023.
//

import SwiftUI

extension Font {
    static func custom(style: CustomFontStyles, italic: Bool = false) -> Font {
        switch style {
        case .extraLargeTitle:
            return Font.custom(italic ? CustomFonts.poppinsBoldItalic.rawValue : CustomFonts.poppinsBold.rawValue, size: style.rawValue, relativeTo: .largeTitle)
        case .extraLargeTitle2:
            return Font.custom(italic ? CustomFonts.poppinsBoldItalic.rawValue : CustomFonts.poppinsBold.rawValue, size: style.rawValue, relativeTo: .largeTitle)
        case .title:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .title)
        case .largeTitle:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .largeTitle)
        case .title2:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .title2)
        case .title3:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .title3)
        case .headline:
            return Font.custom(italic ? CustomFonts.poppinsSemiBoldItalic.rawValue : CustomFonts.poppinsSemiBold.rawValue, size: style.rawValue, relativeTo: .headline)
        case .body:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .body)
        case .callout:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .callout)
        case .subheadline:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .subheadline)
        case .footnote:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .footnote)
        case .caption:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .caption)
        case .caption2:
            return Font.custom(italic ? CustomFonts.poppinsItalic.rawValue : CustomFonts.poppinsRegular.rawValue, size: style.rawValue, relativeTo: .caption2)
        }
    }
}
