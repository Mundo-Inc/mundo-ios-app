//
//  FirstLoadingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct FirstLoadingView: View {
    @ObservedObject var auth = Authentication.shared
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var network: NetworkMonitor
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    @State private var retries: Int = 1
    
    func retry() async {
        if auth.currentUser == nil {
            withAnimation {
                retries += 1
            }
            await auth.updateUserInfo()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                Task {
                    await retry()
                }
            }
        }
    }
    
    @State private var rotationAngle: Double = 0
    
    @State private var offset: CGFloat = 0
    private let animationDuration: Double = 8.0
    private let verticalRepeats: Int = Int(UIScreen.main.bounds.height / 120)
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<verticalRepeats, id: \.self) { _ in
                HStack(spacing: 20) {
                    ForEach(0..<10, id: \.self) { _ in
                        Image(.textLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140)
                    }
                }
                .frame(height: 60)
                .offset(x: offset)
                
                HStack(spacing: 20) {
                    ForEach(0..<6, id: \.self) { _ in
                        Image(.textLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140)
                    }
                }
                .frame(height: 60)
                .offset(x: -offset)
            }
        }
        .foregroundStyle(.white.opacity(0.35))
        .opacity(0.3)
        .rotationEffect(.degrees(5))
        .ignoresSafeArea()
        .background(Color.black)
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.5)))
        .frame(maxWidth: mainWindowSize.width)
        .zIndex(100)
        .onAppear {
            withAnimation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                offset = 140 + 20
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                Task {
                    await retry()
                }
            }
        }
        
        if network.isConnected {
            VStack(spacing: 30) {
                Image(.fullPhantom)
                    .shadow(color: Color.phantom, radius: 130, y: 30)
                Image(.textLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125)
                    .foregroundStyle(.white)
                
                if retries == 2 {
                    Text("Weird, It should not take this long")
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal)
                } else if retries >= 3 {
                    Button {
                        if let url = URL(string: "mailto:admin@phantomphood.com") {
                            openURL(url)
                        }
                    } label: {
                        Label(
                            title: { Text("Contact Support") },
                            icon: { Image(systemName: "envelope.fill.badge.shield.trailinghalf.fill") }
                        )
                        .foregroundStyle(.white.opacity(0.7))
                    }
                    .buttonStyle(.bordered)
                    
                    Text("Hello, Team Extraordinary! It looks like our app's main screen is playing a game of hide and seek and is currently winning. I can't seem to find it anywhere. Could you lend your superpowers to help us spot it? Thanks a bunch!")
                        .padding(.horizontal)
                        .foregroundStyle(.white.opacity(0.7))
                    
                    Button {
                        auth.signOut()
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .font(.custom(style: .subheadline))
            .transition(AnyTransition.opacity.combined(with: .scale(scale: 2)).animation(.easeInOut(duration: 0.75)))
            .zIndex(101)
        } else {
            Group {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView("No Internet", systemImage: "wifi.exclamationmark", description: Text("Please check your internet connection and try again."))
                } else {
                    VStack {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.bottom, 5)
                        
                        Text("No Internet")
                            .font(.custom(style: .title2))
                            .fontWeight(.bold)
                        
                        Text("Please check your internet connection and try again.")
                            .font(.custom(style: .body))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                }
            }
            .preferredColorScheme(.dark)
            .onDisappear {
                retries = 1
            }
            .zIndex(101)
        }
    }
}

#Preview {
    ZStack {
        FirstLoadingView()
            .environmentObject(NetworkMonitor())
    }
}
