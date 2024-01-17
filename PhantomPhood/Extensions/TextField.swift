//
//  TextField.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation
import SwiftUI

enum TextFieldSize: CGFloat {
    /// 38 points
    case small = 38

    /// 46 points
    /// - Default size
    case medium = 46

    /// 52 points
    case large = 52
}


struct FilledTextFieldViewModifier: ViewModifier {
    let size: TextFieldSize
    let paddingLeading: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .font(.custom(style: .headline))
            .fontWeight(.regular)
            .padding(.leading, paddingLeading)
            .frame(height: size.rawValue)
            .background(Color.themePrimary)
            .cornerRadius(8)
    }
}
