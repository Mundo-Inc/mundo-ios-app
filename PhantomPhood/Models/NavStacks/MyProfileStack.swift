//
//  MyProfileStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import Foundation

enum MyProfileStack: Hashable {
    case settings
    case userProfile(id: String)
    case place(id: String)
    
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .settings:
            hasher.combine("settings")
        case .userProfile(let id):
            hasher.combine("userProfile")
            hasher.combine(id)
        case .place(let id):
            hasher.combine("place")
            hasher.combine(id)
        }
    }
}

enum MyProfileActiveTab: String, Hashable, CaseIterable {
    case stats = "Stats"
    case achievements = "Acheivements"
    case activity = "Activity"
}
