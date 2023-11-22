//
//  SignInOptionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/21/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class SignInOptionsVM: ObservableObject {
    @ObservedObject var auth = Authentication.shared
    
    @Published var error: String? = nil
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let result = await auth.signinWithGoogle(tokens: tokens)
        if !result.success {
            self.error = result.error
        }
    }
    
    func signInApple() async throws {
        let helper = SignInWithAppleHelper.shared
        let tokens = try await helper.startSignInWithAppleFlow()
        let result = await auth.signinWithApple(tokens: tokens)
        if !result.success {
            self.error = result.error
        }
    }
}

struct SignInOptionsView: View {
    @StateObject var vm = SignInOptionsVM()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            VStack(alignment: .leading) {
                Text("Welcome Back")
                    .font(.custom(style: .title2))
                    .fontWeight(.semibold)
                Text("Please choose how you want to sign in")
                    .font(.custom(style: .subheadline))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .alert("Error", isPresented: Binding(optionalValue: $vm.error)) {
                        Button(role: .cancel) {
                            vm.error = nil
                        } label: {
                            Text("Ok")
                        }
                    } message: {
                        Text(vm.error ?? "")
                    }
                
                
                VStack {
                    Button {
                        Task {
                            do {
                                try await vm.signInApple()
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        SignInWithAppleButtonViewRepresentable(type: .default, style: colorScheme == .dark ? .white : .black)
                            .allowsHitTesting(false)
                            .frame(height: 38)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: colorScheme == .dark ? .light : .dark, style: .wide, state: .normal)) {
                        Task {
                            do {
                                try await vm.signInGoogle()
                            } catch {
                                print(error)
                            }
                        }
                    }
                    .frame(height: 38)
                    .clipShape(.rect(cornerRadius: 10))
                    
                    Text("- Or -")
                        .font(.custom(style: .subheadline))
                        .foregroundStyle(.secondary)
                    
                    NavigationLink(value: AuthStack.signinWithEmail) {
                        Label(
                            title: { Text("Using Email and Password") },
                            icon: { Image(systemName: "envelope.fill") }
                        )
                        .font(.custom(style: .footnote))
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(colorScheme == .dark ? .white : .black)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .clipShape(.rect(cornerRadius: 10))
                    }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            
            Spacer()
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
    SignInOptionsView()
}
