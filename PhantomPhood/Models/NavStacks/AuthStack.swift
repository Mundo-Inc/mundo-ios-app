//
//  AuthStack.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import Foundation

enum AuthStack: Hashable {
    case signin
    case signup
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .signin:
            hasher.combine("signin")
        case .signup:
            hasher.combine("signup")
        }
    }
}
