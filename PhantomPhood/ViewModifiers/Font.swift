//
//  Font.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/10/24.
//

import SwiftUI

struct CustomFontViewModifier: ViewModifier {
    let textStyle: Font.TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(.custom(K.Fonts.satoshi, size: textStyle.size, relativeTo: textStyle))
    }
}
