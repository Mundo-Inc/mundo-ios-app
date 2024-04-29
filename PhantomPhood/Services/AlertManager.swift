//
//  AlertManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/1/24.
//

import Foundation
import SwiftUI

final class AlertManager: ObservableObject {
    @Published var value: AlertInfo? = nil
    
    struct AlertInfo {
        let message: String
        let confirmationText: String
        let role: ButtonRole?
        let callback: () -> Void
        
        init(message: String, confirmationText: String = "Yes", role: ButtonRole? = nil, callback: @escaping () -> Void) {
            self.message = message
            self.confirmationText = confirmationText
            self.role = role
            self.callback = callback
        }
    }
}
