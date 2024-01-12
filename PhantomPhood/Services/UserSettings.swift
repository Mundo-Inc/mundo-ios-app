//
//  UserSettings.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/12/24.
//

import Foundation
import SwiftUI

struct UserSettings {
    static let shared = UserSettings()

    private init() {}
    
    @AppStorage("userRole") var userRole: UserRole = .user
    
    @AppStorage("isBetaTester") var isBetaTester: Bool = false

    /// Reset all settings to default values
    func reset() {
        userRole = .user
        isBetaTester = false
    }
}

