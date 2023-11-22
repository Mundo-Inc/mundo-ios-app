//
//  AuthStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import Foundation

enum AuthStack: Hashable {
    case signinOptions
    case signinWithEmail
    case signup
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .signinOptions:
            hasher.combine("signinOptions")
        case .signinWithEmail:
            hasher.combine("signinWithEmail")
        case .signup:
            hasher.combine("signup")
        }
    }
}
