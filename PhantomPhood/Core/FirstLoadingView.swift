//
//  FirstLoadingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct FirstLoadingView: View {
    @ObservedObject var auth = Authentication.shared
    @Environment(\.openURL) var openURL
    
    @State var retries: Int = 1
    
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
    
    @State var rotationAngle: Double = 0
    
    @State private var offset: CGFloat = 0
    private let animationDuration: Double = 8.0
    private let verticalRepeats: Int = Int(UIScreen.main.bounds.height / 120)
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image("FullPhantom")
                    .shadow(color: Color(.phantom), radius: 130, y: 30)
                Image(.textLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 125)
                    .foregroundStyle(.white)
                
                if retries == 2 {
                    Text("Weird, It should not take this long")
                        .foregroundStyle(.secondary)
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
                    }
                    .buttonStyle(.bordered)
                    
                    Text("Hello, Team Extraordinary! It looks like our app's main screen is playing a game of hide and seek and is currently winning. I can't seem to find it anywhere. Could you lend your superpowers to help us spot it? Thanks a bunch!")
                        .padding(.horizontal)
                }
            }
            .background {
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
                .foregroundStyle(.tertiary)
                .opacity(0.3)
                .rotationEffect(.degrees(5))
                .ignoresSafeArea()
            }
            .preferredColorScheme(.dark)
            .font(.custom(style: .subheadline))
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
        }
    }
}

#Preview {
    FirstLoadingView()
}
