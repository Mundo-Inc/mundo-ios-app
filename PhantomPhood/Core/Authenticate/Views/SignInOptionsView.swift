//
//  SignInOptionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/21/23.
//

import SwiftUI

struct SignInOptionsView: View {
    @StateObject private var vm = OAuthVM()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Welcome Back")
                        .cfont(.title2)
                        .fontWeight(.semibold)
                    Text("Please choose how you want to sign in")
                        .cfont(.subheadline)
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
                                    try? await vm.signInApple()
                                }
                            } label: {
                                Image(.signInIconOnlyApple)
                            }
                            
                            Divider()
                                .frame(maxHeight: 30)
                            
                            Button {
                                Task {
                                    try? await vm.signInGoogle()
                                }
                            } label: {
                                Image(.signInIconOnlyGoogle)
                            }
                        }
                        
                        Text("-- Or --")
                            .cfont(.subheadline)
                            .foregroundStyle(.tertiary)
                            .padding(.vertical, 10)
                        
                        NavigationLink(value: AuthRoute.signInWithPassword) {
                            Label(
                                title: { Text("Using Email and Password") },
                                icon: { Image(systemName: "envelope.fill") }
                            )
                            .cfont(.footnote)
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
        .background(alignment: .topTrailing) {
            Image(.Logo.tpLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .rotationEffect(.degrees(-90))
                .offset(x: 55, y: 20)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    SignInOptionsView()
}
