//
//  AuthRoute.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import Foundation

enum AuthRoute: Hashable {
    case signInOptions
    case signInWithPassword
    case signUpOptions
    case signUpWithPassword
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .signInOptions:
            hasher.combine("signInOptions")
        case .signInWithPassword:
            hasher.combine("signInWithPassword")
        case .signUpOptions:
            hasher.combine("signUpOptions")
        case .signUpWithPassword:
            hasher.combine("signUpWithPassword")
        }
    }
}
