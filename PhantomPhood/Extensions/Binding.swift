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
    
    init<T: Equatable>(optionalValue: Binding<T?>, ofCase: T) {
        self.init {
            if let value = optionalValue.wrappedValue {
                if case ofCase = value {
                    return true
                }
            }
            return false
        } set: { newValue in
            if !newValue {
                optionalValue.wrappedValue = nil
            }
        }

    }
}
