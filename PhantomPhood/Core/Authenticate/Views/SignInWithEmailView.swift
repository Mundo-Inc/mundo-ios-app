//
//  SignInWithEmailView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/21/23.
//

import SwiftUI

struct SignInWithEmailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var vm = SignInVM()
    
    enum TextFields: Hashable {
        case email
        case password
        case resetEmail
    }
    
    @FocusState private var focusedField: TextFields?
    
    var body: some View {
        VStack {
            Spacer(minLength: 0)
            
            VStack(alignment: .leading) {
                Image(.lock)
                Text("Welcome Back")
                    .font(.custom(style: .title2))
                    .fontWeight(.semibold)
                Text("Sign in to continue")
                    .font(.custom(style: .subheadline))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            .alert("Error", isPresented: Binding(optionalValue: $vm.error)) {
                Button(role: .cancel) {
                    vm.error = nil
                } label: {
                    Text("Ok")
                }
            } message: {
                Text(vm.error ?? "")
            }
            
            TextField("Email", text: $vm.email)
                .withFilledStyle()
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
                .textContentType(UITextContentType.emailAddress)
                .focused($focusedField, equals: .email)
                .onChange(of: vm.email) { newValue in
                    withAnimation {
                        if !Validator.email(newValue) {
                            vm.isValidEmail = false
                        } else {
                            vm.isValidEmail = true
                        }
                    }
                }
            
            if vm.email.count > 0 && !vm.isValidEmail {
                Text("Invalid email address")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom(style: .caption))
                    .foregroundColor(.red)
            }
            
            SecureField("Password", text: $vm.password)
                .withFilledStyle()
                .textContentType(UITextContentType.password)
                .focused($focusedField, equals: .password)
            
            Button {
                vm.showResetPassword = true
            } label: {
                Text("Recover my password")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.custom(style: .caption))
            }
            .sheet(isPresented: $vm.showResetPassword) {
                VStack {
                    VStack(alignment: .leading) {
                        Image(.lock)
                        Text("Reset Password")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .title2))
                            .fontWeight(.semibold)
                        Text("We will send you an email containing a link to reset your password.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .subheadline))
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
                        .onChange(of: vm.email) { newValue in
                            withAnimation {
                                if !Validator.email(newValue) {
                                    vm.isValidEmail = false
                                } else {
                                    vm.isValidEmail = true
                                }
                            }
                        }
                    
                    if vm.email.count > 0 && !vm.isValidEmail {
                        Text("Invalid email address")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .caption))
                            .foregroundColor(.red)
                    }
                    
                    Button {
                        Task {
                            withAnimation {
                                vm.isLoading = true
                            }
                            do {
                                try await Authentication.shared.requestResetPassword(email: vm.email)
                                vm.showResetPassword = false
                                ToastVM.shared.toast(.init(type: .success, title: "Email Sent", message: "Email sent"))
                            } catch {
                                presentErrorToast(error)
                            }
                            withAnimation {
                                vm.isLoading = false
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            if vm.isLoading {
                                ProgressView()
                                    .controlSize(.regular)
                            }
                            Text("Send")
                        }
                        .font(.custom(style: .subheadline))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.bottom)
                    .disabled(
                        vm.isLoading ||
                        vm.email.count == 0 ||
                        !vm.isValidEmail
                    )
                }
                .padding(.horizontal)
            }
            
            Spacer()
            Spacer()
            
            Button {
                Task {
                    withAnimation {
                        vm.isLoading = true
                    }
                    let result = await Authentication.shared.signIn(email: vm.email, password: vm.password)
                    if let error = result.error, !result.success {
                        withAnimation {
                            vm.error = error
                        }
                    }
                    withAnimation {
                        vm.isLoading = false
                    }

                }
            } label: {
                HStack(spacing: 5) {
                    if vm.isLoading {
                        ProgressView()
                            .controlSize(.regular)
                    }
                    Text("Sign In")
                }
                .font(.custom(style: .subheadline))
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom)
            .disabled(
                vm.isLoading ||
                vm.email.count == 0 ||
                !vm.isValidEmail ||
                vm.password.count < 5
            )
            
        }
        .onAppear {
            if vm.email.count < 3 {
                focusedField = .email
            } else if vm.password.count < 5 {
                focusedField = .password
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    SignInWithEmailView()
}
