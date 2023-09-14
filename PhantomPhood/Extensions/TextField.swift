//
//  TextField.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation
import SwiftUI

struct FilledTextFieldViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding()
            .background(Color.themePrimary)
            .cornerRadius(10)
    }
}

extension TextField {
    func withFilledStyle() -> some View {
        modifier(FilledTextFieldViewModifier())
    }
}

extension SecureField {
    func withFilledStyle() -> some View {
        modifier(FilledTextFieldViewModifier())
    }
}
