//
//  WelcomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI
import Lottie

struct WelcomeView: View {
    @ObservedObject var appData = AppData.shared
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            NavigationStack(path: $appData.authNavStack) {
                VStack {
                    Spacer()
                    
                    Image("TextLogo")
                        .resizable()
                        .foregroundColor(.primary)
                        .scaledToFit()
                        .frame(width: 120)
                    
                    
                    Spacer()
                    
                    LottieView(file: .welcome, loop: true)
                        .frame(width: UIScreen.main.bounds.width + 10, height: UIScreen.main.bounds.width + 10)
                        
                    
                    Spacer()
                    
                    NavigationLink(value: AuthStack.signup) {
                        Text("Create an Account")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                    
                    NavigationLink(value: AuthStack.signinOptions) {
                        Text("I already have an account")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.large)
                    .padding(.horizontal)
                    
                }
                .toolbar(.hidden, for: .automatic)
                .navigationTitle("Welcome")
                .navigationDestination(for: AuthStack.self) { link in
                    switch link {
                    case .signup:
                        SignUpView()
                    case .signinOptions:
                        SignInOptionsView()
                    case .signinWithEmail:
                        SignInWithEmailView()
                    }
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}



