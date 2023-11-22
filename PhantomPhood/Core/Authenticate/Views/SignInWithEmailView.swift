//
//  SignInWithEmailView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/21/23.
//

import SwiftUI

// MARK: - Data Manager
class SignInDataManager {
    
    // MARK: - Nested Types
    struct ServerError: Codable {
        let success: Bool
        let error: ErrorRes
        
        struct ErrorRes: Codable {
            let message: String
        }
    }
    
    // MARK: - API Manager
    
    private let apiManager = APIManager.shared
    
    
    // MARK: - Public Methods
    func checkUsername(_ username: String) async throws -> HTTPURLResponse {
        let response = try await apiManager.requestNoContent("/users/username-availability/\(username)")
        return response
    }
    
}

// MARK: - ViewModel
@MainActor
class SignInViewModel: ObservableObject {
    private let dataManager = SignUpDataManager()
    
    @Published var isLoading = false
    
    @Published var email: String = ""
    @Published var isValidEmail: Bool = false
    @Published var password: String = ""
    
    @Published var error: String?
    
}

// MARK: - View
struct SignInWithEmailView: View {
    @ObservedObject var auth = Authentication.shared
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var vm = SignInViewModel()
    
    enum TextFields: Hashable {
        case email
        case password
    }
    
    @FocusState private var focusedField: TextFields?
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            VStack(alignment: .leading) {
                Image(.lock)
                Text("Welcome Back")
                    .font(.custom(style: .title2))
                    .fontWeight(.semibold)
                Text("Sign in to continue")
                    .font(.custom(style: .subheadline))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            .alert("Error", isPresented: Binding(optionalValue: $vm.error)) {
                Button(role: .cancel) {
                    vm.error = nil
                } label: {
                    Text("Ok")
                }
            } message: {
                Text(vm.error ?? "")
            }
            
            TextField("Email", text: $vm.email)
                .withFilledStyle()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
                .textContentType(UITextContentType.emailAddress)
                .focused($focusedField, equals: .email)
                .onChange(of: vm.email) { newValue in
                    withAnimation {
                        if !Validator.email(newValue) {
                            vm.isValidEmail = false
                        } else {
                            vm.isValidEmail = true
                        }
                    }
                }
            
            if vm.email.count > 0 && !vm.isValidEmail {
                Text("Invalid email address")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(style: .caption))
                    .foregroundColor(.red)
            }
            
            SecureField("Password", text: $vm.password)
                .withFilledStyle()
                .textContentType(UITextContentType.password)
                .focused($focusedField, equals: .password)
            
            Button("Recover my password") {
                if let url = URL(string: "https://phantomphood.ai/reset-password") {
                    UIApplication.shared.open(url)
                }
            }.frame(maxWidth: .infinity, alignment: .trailing)
            
            Spacer()
            Spacer()
            
            Button {
                withAnimation {
                    vm.isLoading = true
                }
                Task {
                    let result = await auth.signin(email: vm.email, password: vm.password)
                    if let error = result.error, !result.success {
                        withAnimation {
                            vm.error = error
                        }
                    }
                }
                withAnimation {
                    vm.isLoading = false
                }
            } label: {
                HStack(spacing: 5) {
                    if vm.isLoading {
                        ProgressView()
                            .controlSize(.regular)
                    }
                    Text("Sign In")
                }
                .font(.custom(style: .subheadline))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom)
            .disabled(
                vm.isLoading ||
                vm.email.count == 0 ||
                !vm.isValidEmail ||
                vm.password.count < 5
            )
            
        }
        .onAppear {
            if vm.email.count < 3 {
                focusedField = .email
            } else if vm.password.count < 5 {
                focusedField = .password
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(.hangingPhantom)
                .resizable()
                .frame(width: 100, height: 191)
                .padding(.trailing)
                .ignoresSafeArea(),
            alignment: .topTrailing
        )
    }
}



#Preview {
    SignInWithEmailView()
}
