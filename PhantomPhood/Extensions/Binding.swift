//
//  Binding.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/30/23.
//

import Foundation
import SwiftUI

extension Binding where Value == Bool {
    
    init<T>(optionalValue: Binding<T?>) {
        self.init {
            optionalValue.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                optionalValue.wrappedValue = nil
            }
        }
    }
    
}
