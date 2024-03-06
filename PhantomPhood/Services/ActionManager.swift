//
//  ActionManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/1/24.
//

import Foundation

final class ActionManager: ObservableObject {
    @Published var value: [Action]? = nil
    
    struct Action: Identifiable {
        let id = UUID()
        let title: String
        let alertMessage: String?
        let callback: () -> Void
        
        init(title: String, alertMessage: String?, callback: @escaping () -> Void) {
            self.title = title
            self.alertMessage = alertMessage
            self.callback = callback
        }
        
        init(title: String, callback: @escaping () -> Void) {
            self.title = title
            self.alertMessage = nil
            self.callback = callback
        }
    }
}
