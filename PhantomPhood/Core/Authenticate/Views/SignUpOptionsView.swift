//
//  SignUpOptionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/23/23.
//

import SwiftUI

struct SignUpOptionsView: View {
    @StateObject private var vm = OAuthVM()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Create an account")
                        .font(.custom(style: .title2))
                        .fontWeight(.semibold)
                    Text("Please choose how you want to sign up")
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
                        
                        HStack(spacing: 20) {
                            Button {
                                Task {
                                    do {
                                        try await vm.signInApple()
                                    } catch {
                                        print(error)
                                    }
                                }
                            } label: {
                                Image(.signInIconOnlyApple)
                            }
                            
                            Divider()
                                .frame(maxHeight: 30)
                            
                            Button {
                                Task {
                                    do {
                                        try await vm.signInGoogle()
                                    } catch {
                                        print(error)
                                    }
                                }
                            } label: {
                                Image(.signInIconOnlyGoogle)
                            }
                        }
                        
                        Text("-- Or --")
                            .font(.custom(style: .subheadline))
                            .foregroundStyle(.tertiary)
                            .padding(.vertical, 10)
                        
                        NavigationLink(value: AuthRoute.signUpWithPassword) {
                            Label(
                                title: { Text("Using Email and Password") },
                                icon: { Image(systemName: "envelope.fill") }
                            )
                            .font(.custom(style: .footnote))
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(colorScheme == .dark ? .white : .black)
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                            .clipShape(.rect(cornerRadius: 10))
                        }
                    }
                    .padding(.top)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if vm.isLoading {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.black)
                            .frame(width: 40, height: 40)
                            .overlay {
                                ProgressView()
                                    .tint(.white)
                            }
                    }
            }
        }
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
    SignUpOptionsView()
}
