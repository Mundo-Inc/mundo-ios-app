//
//  SignInView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
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
    
    private let apiManager = APIManager()
    
    
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

struct SignInView: View {
    @EnvironmentObject var auth: Authentication
    @StateObject private var vm = SignInViewModel()
    
    enum Field {
        case email
        case password
    }
    
    @FocusState private var focusedField: Field?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                if let error = vm.error {
                    Text(error)
                        .font(.headline)
                        .foregroundColor(.red)
                        .onTapGesture {
                            vm.error = nil
                        }
                }
                Spacer(minLength: 0)
                
                VStack(alignment: .leading) {
                    Image("Lock")
                    Text("Welcome Back")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom)
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
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
                        .font(.caption)
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
                    Task {
                        withAnimation {
                            vm.isLoading = true
                        }
                        do {
                            let _ = try await auth.signin(email: vm.email, password: vm.password)
                        } catch APIManager.APIError.serverError(let serverError) {
                            withAnimation {
                                vm.error = serverError.message
                            }
                        } catch {
                            withAnimation {
                                vm.error = error.localizedDescription
                            }
                        }
                        
                        vm.isLoading = false
                    }
                } label: {
                    HStack(spacing: 5) {
                        if vm.isLoading {
                            ProgressView()
                                .controlSize(.regular)
                        }
                        Text("Sign In")
                    }.frame(maxWidth: .infinity)
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
                Image("HangingPhantom")
                    .resizable()
                    .frame(width: 100, height: 191)
                    .padding(.trailing)
                    .ignoresSafeArea(),
                alignment: .topTrailing
            )
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(Authentication())
}
