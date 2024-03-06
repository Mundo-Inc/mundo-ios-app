//
//  AlertManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/1/24.
//

import Foundation

final class AlertManager: ObservableObject {
    @Published var value: AlertInfo? = nil
    
    struct AlertInfo {
        let message: String
        let callback: () -> Void
    }
}
