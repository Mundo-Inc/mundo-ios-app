//
//  WelcomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI
import Lottie

struct WelcomeView: View {
    @State private var stackPath: [AuthNavigationModel] = []
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            NavigationStack(path: $stackPath) {
                VStack {
                    Spacer()
                    
                    Image("TextLogo")
                        .resizable()
                        .foregroundColor(.primary)
                        .scaledToFit()
                        .frame(width: 120)
                    
                    
                    Spacer()
                    
                    LottieView(file: .welcome, loop: true)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    
                    Spacer()
                    
                    NavigationLink(value: AuthNavigationModel(screen: .signup)) {
                        Text("Create an Account")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)
                    
                    NavigationLink(value: AuthNavigationModel(screen: .signin)) {
                        Text("I already have an account")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderless)
                    .controlSize(.large)
                    .padding(.horizontal)
                    
                }
                .toolbar(.hidden, for: .automatic)
                .navigationTitle("Welcome")
                .navigationDestination(for: AuthNavigationModel.self) { navModel in
                    switch navModel.screen {
                    case .signup:
                        SignUpView()
                    case .signin:
                        SignInView()
                    }
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}



