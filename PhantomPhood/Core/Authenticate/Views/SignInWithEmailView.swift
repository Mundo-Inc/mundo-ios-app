//
//  SignInWithEmailView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/21/23.
//

import SwiftUI

struct SignInWithEmailView: View {
    enum Field: Hashable {
        case email
        case password
        case resetEmail
    }
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    @StateObject private var vm = SignInVM()
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Image(.lock)
                    Text("Welcome Back")
                        .cfont(.title2)
                        .fontWeight(.semibold)
                    Text("Sign in to continue")
                        .cfont(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                TextField("Email", text: $vm.email)
                    .withFilledStyle()
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.emailAddress)
                    .textContentType(UITextContentType.emailAddress)
                    .focused($focusedField, equals: .email)
                    .overlay(alignment: .trailing) {
                        if vm.email.count > 0 && !vm.isValidEmail {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                                .padding(.trailing, 10)
                                .transition(AnyTransition.asymmetric(insertion: .scale, removal: .opacity).animation(.spring(duration: 0.2)))
                        }
                    }
                
                SecureField("Password", text: $vm.password)
                    .withFilledStyle()
                    .textContentType(UITextContentType.password)
                    .focused($focusedField, equals: .password)
                    .overlay(alignment: .trailing) {
                        if vm.password.count > 0 && !vm.isValidPassword {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)
                                .padding(.trailing, 10)
                                .transition(AnyTransition.asymmetric(insertion: .scale, removal: .opacity).animation(.spring(duration: 0.2)))
                        }
                    }
                
                Button {
                    vm.showResetPassword = true
                } label: {
                    Text("Recover my password")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .cfont(.body)
                }
                .alert("Error", isPresented: Binding(optionalValue: $vm.error)) {
                    Button(role: .cancel) {
                        vm.error = nil
                    } label: {
                        Text("Ok")
                    }
                } message: {
                    Text(vm.error ?? "")
                }
                .sheet(isPresented: $vm.showResetPassword) {
                    VStack {
                        VStack(alignment: .leading) {
                            Image(.lock)
                            Text("Reset Password")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cfont(.title2)
                                .fontWeight(.semibold)
                            Text("We will send you an email containing a link to reset your password.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cfont(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.bottom)
                        
                        TextField("Email", text: $vm.email)
                            .withFilledStyle()
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress)
                            .textContentType(UITextContentType.emailAddress)
                            .focused($focusedField, equals: .resetEmail)
                            .overlay(alignment: .trailing) {
                                if vm.email.count > 0 && !vm.isValidEmail {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                        .padding(.trailing, 10)
                                        .transition(AnyTransition.asymmetric(insertion: .scale, removal: .opacity).animation(.spring(duration: 0.2)))
                                }
                            }
                        
                        let isResetPasswordLoading = vm.loadingSections.contains(.requestPasswordReset)
                        
                        CButton(
                            fullWidth: true,
                            size: .lg,
                            variant: .primary,
                            text: "Send",
                            isLoading: isResetPasswordLoading
                        ) {
                            Task {
                                await vm.requestPasswordReset()
                            }
                        }
                        .disabled(isResetPasswordLoading || !vm.isValidEmail)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, mainWindowSize.height / 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .overlay(alignment: .bottom) {
            CButton(
                fullWidth: true,
                size: .lg,
                variant: .primary,
                text: "Sign In",
                isLoading: vm.loadingSections.contains(.signIn)
            ) {
                Task {
                    await vm.signIn()
                }
            }
            .disabled(vm.loadingSections.contains(.signIn) || !vm.isValidEmail || !vm.isValidPassword)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(alignment: .topTrailing) {
            Image(.Logo.tpLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .rotationEffect(.degrees(-90))
                .offset(x: 55, y: 20)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onAppear {
            if !vm.isValidEmail {
                focusedField = .email
            } else if !vm.isValidPassword {
                focusedField = .password
            }
        }
    }
}

#Preview {
    SignInWithEmailView()
}
