//
//  SignInVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/8/24.
//

import Foundation

@MainActor
final class SignInVM: ObservableObject {
    @Published var isLoading = false
    
    @Published var email: String = ""
    @Published var isValidEmail: Bool = false
    @Published var password: String = ""
    
    @Published var error: String?
    
    @Published var showResetPassword = false
}
