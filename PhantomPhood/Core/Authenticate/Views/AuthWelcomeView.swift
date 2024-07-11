//
//  AuthWelcomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI

struct AuthWelcomeView: View {
    @ObservedObject private var appData = AppData.shared
    
    var body: some View {
        ZStack {
            Color(.themeBG).ignoresSafeArea()
            
            NavigationStack(path: $appData.authNavStack) {
                VStack {
                    Spacer()
                    
                    Text("MUNDO")
                        .opacity(0.8)
                        .fontWeight(.bold)
                        .cfont(.title)
                        .frame(width: 120)
                    
                    Spacer()
                    
                    LottieView(file: .welcome, loop: true)
                        .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.width + 10)
                    
                    Spacer()
                    
                    NavigationLink(value: AuthRoute.signUpOptions) {
                        Text("Create an Account")
                            .cfont(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                    
                    NavigationLink(value: AuthRoute.signInOptions) {
                        Text("I already have an account")
                            .cfont(.headline)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.large)
                    .padding(.horizontal)
                    
                }
                .toolbar(.hidden, for: .automatic)
                .navigationTitle("Welcome")
                .navigationDestination(for: AuthRoute.self) { link in
                    switch link {
                    case .signUpOptions:
                        SignUpOptionsView()
                    case .signUpWithPassword:
                        SignUpWithPasswordView()
                    case .signInOptions:
                        SignInOptionsView()
                    case .signInWithPassword:
                        SignInWithEmailView()
                    }
                }
            }
        }
    }
}

#Preview {
    AuthWelcomeView()
}



