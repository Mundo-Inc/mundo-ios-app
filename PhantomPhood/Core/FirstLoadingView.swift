//
//  FirstLoadingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct FirstLoadingView: View {
    @ObservedObject private var auth = Authentication.shared
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var network: NetworkMonitor
    
    @State private var retries: Int = 1
    
    func retry() async {
        guard auth.currentUser == nil else { return }
        
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
    
    var body: some View {
        ZStack {
            if network.isConnected {
                VStack(spacing: 25) {
                    Image(.Logo.tpLogo)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                    
                    if retries == 2 {
                        Text("Trying to get your information from server...")
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal)
                        
                        Color.clear
                            .frame(height: 30)
                    } else if retries >= 3 {
                        Button {
                            if let url = URL(string: "mailto:\(K.ENV.SupportEmail)") {
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
                        
                        Text("Oops, Something is Wrong!")
                            .foregroundStyle(.white.opacity(0.8))
                            .fontWeight(.semibold)
                        
                        Text("We’re encountering some difficulty fetching your information at the moment. This might be due to an unexpected hiccup on our end, a network glitch, or a restriction based on your current location.")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                .cfont(.subheadline)
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        if retries >= 3 {
                            Button {
                                Task {
                                    await auth.signOut()
                                }
                            } label: {
                                Text("Sign Out")
                            }
                            
                            Spacer()
                        }
                        
                        ProgressView()
                    }
                    .padding(.horizontal)
                }
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
                                .cfont(.title2)
                                .fontWeight(.bold)
                            
                            Text("Please check your internet connection and try again.")
                                .cfont(.body)
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
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .transition(AnyTransition.opacity.combined(with: .scale(scale: 2)).animation(.easeInOut(duration: 0.75)))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                Task {
                    await retry()
                }
            }
        }
    }
}

#Preview {
    ZStack {
        FirstLoadingView()
            .environmentObject(NetworkMonitor())
    }
}
