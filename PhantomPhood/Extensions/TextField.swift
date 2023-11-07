//
//  TextField.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation
import SwiftUI

enum TextFieldSize: CGFloat {
    case small = 7
    case medium = 11
    case large = 14
}


struct FilledTextFieldViewModifier: ViewModifier {
    let size: TextFieldSize
    let paddingLeading: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .font(.custom(style: .headline))
            .fontWeight(.regular)
            .padding(.leading, paddingLeading)
            .padding(.vertical, size.rawValue)
            .background(Color.themePrimary)
            .cornerRadius(8)
    }
}

extension TextField {
    func withFilledStyle(size: TextFieldSize = .medium, paddingLeading: CGFloat? = nil) -> some View {
        modifier(FilledTextFieldViewModifier(size: size, paddingLeading: paddingLeading))
    }
}

extension SecureField {
    func withFilledStyle(size: TextFieldSize = .medium, paddingLeading: CGFloat? = nil) -> some View {
        modifier(FilledTextFieldViewModifier(size: size, paddingLeading: paddingLeading))
    }
}
