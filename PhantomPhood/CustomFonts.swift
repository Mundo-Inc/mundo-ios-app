//
//  CustomFonts.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 22.09.2023.
//

import Foundation

/*
 Poppins
 -- Poppins-Regular
 -- Poppins-Italic
 -- Poppins-Thin
 -- Poppins-ThinItalic
 -- Poppins-ExtraLight
 -- Poppins-ExtraLightItalic
 -- Poppins-Light
 -- Poppins-LightItalic
 -- Poppins-Medium
 -- Poppins-MediumItalic
 -- Poppins-SemiBold
 -- Poppins-SemiBoldItalic
 -- Poppins-Bold
 -- Poppins-BoldItalic
 -- Poppins-ExtraBold
 -- Poppins-ExtraBoldItalic
 -- Poppins-Black
 -- Poppins-BlackItalic
 */

enum CustomFonts: String {
    case poppinsRegular = "Poppins-Regular"
    case poppinsItalic = "Poppins-Italic"
    
    case poppinsThin = "Poppins-Thin"
    case poppinsThinItalic = "Poppins-ThinItalic"
    
    case poppinsExtraLight = "Poppins-ExtraLight"
    case poppinsExtraLightItalic = "Poppins-ExtraLightItalic"
    
    case poppinsLight = "Poppins-Light"
    case poppinsLightItalic = "Poppins-LightItalic"
    
    case poppinsMedium = "Poppins-Medium"
    case poppinsMediumItalic = "Poppins-MediumItalic"
    
    case poppinsSemiBold = "Poppins-SemiBold"
    case poppinsSemiBoldItalic = "Poppins-SemiBoldItalic"
    
    case poppinsBold = "Poppins-Bold"
    case poppinsBoldItalic = "Poppins-BoldItalic"
    
    case poppinsExtraBold = "Poppins-ExtraBold"
    case poppinsExtraBoldItalic = "Poppins-ExtraBoldItalic"

    case poppinsBlack = "Poppins-Black"
    case poppinsBlackItalic = "Poppins-BlackItalic"

}

enum CustomFontStyles: CGFloat {
    case extraLargeTitle = 36
    case extraLargeTitle2, title = 28
    case largeTitle = 34
    case title2 = 22
    case title3 = 20
    case headline, body = 16
    case subheadline, callout = 15
    case footnote = 13
    case caption = 12
    case caption2 = 11
}
