//
//  AuthWelcomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI
import Lottie

struct AuthWelcomeView: View {
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    @ObservedObject private var appData = AppData.shared
    @State private var playbackMode: LottiePlaybackMode = .paused
    
    var body: some View {
        NavigationStack(path: $appData.authNavStack) {
            VStack {
                Spacer()
                
                Text("MUNDO")
                    .opacity(0.8)
                    .fontWeight(.bold)
                    .cfont(.title)
                    .frame(width: 120)
                
                Spacer()
                
                LottieView(animation: .named("Welcome"))
                    .playbackMode(playbackMode)
                    .frame(width: mainWindowSize.width + 10, height: mainWindowSize.width + 10)
                    .onAppear {
                        playbackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
                        
                    }
                    .onDisappear {
                        playbackMode = .paused
                    }
                
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
            .toolbar(.hidden, for: .navigationBar)
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
        .background(Color(.themeBG).ignoresSafeArea())
    }
}

#Preview {
    AuthWelcomeView()
}



