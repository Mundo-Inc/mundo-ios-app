//
//  UserProfileStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation

enum UserProfileStack: String, CaseIterable {
    case usersProfile = "UsersProfile"
    case place = "Place"

    static func convert(from: String) -> Self? {
        return UserProfileStack.allCases.first { stack in
            stack.rawValue.lowercased() == from.lowercased()
        }
    }
}
