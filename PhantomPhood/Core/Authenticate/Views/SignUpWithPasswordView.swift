//
//  LoginScreen.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI
import BranchSDK

// MARK: - View

struct SignUpWithPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.mainWindowSize) private var mainWindowSize
    @AppStorage(K.UserDefaults.referredBy) private var referredBy: String = ""
    
    @StateObject private var vm = SignUpWithPasswordVM()
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case email
        case name
        case username
        case password
        case userSearch
    }
    
    var body: some View {
        ZStack {
            Group {
                switch vm.step {
                case .email:
                    emailView
                        .tag(SignUpWithPasswordVM.Step.email)
                case .name:
                    nameView
                        .tag(SignUpWithPasswordVM.Step.name)
                case .username:
                    usernameView
                        .tag(SignUpWithPasswordVM.Step.username)
                case .password:
                    passwordView
                        .tag(SignUpWithPasswordVM.Step.password)
                case .referral:
                    referralView
                        .tag(SignUpWithPasswordVM.Step.referral)
                case .tos:
                    tosView
                        .tag(SignUpWithPasswordVM.Step.tos)
                }
            }
            .transition(
                AnyTransition.asymmetric(
                    insertion: AnyTransition.move(edge: vm.direction == 1 ? .trailing : .leading),
                    removal: AnyTransition.move(edge: vm.direction == 1 ? .leading : .trailing)
                )
            )
            .animation(.spring(duration: 0.5), value: vm.step)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbarBackground(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
            if let error = vm.error {
                Text(error)
                    .cfont(.headline)
                    .foregroundColor(.red)
                    .onTapGesture {
                        vm.error = nil
                    }
                    .transition(AnyTransition.scale.combined(with: .opacity).animation(.easeIn))
            }
        }
        .overlay(alignment: .bottom) {
            HStack {
                CButton(fullWidth: true, size: .lg, variant: .ghost, text: vm.step.backButtonTitle) {
                    switch vm.step {
                    case .email:
                        vm.direction = 1
                        dismiss()
                    case .name:
                        vm.direction = -1
                        withAnimation {
                            vm.step = .email
                        }
                    case .username:
                        vm.direction = -1
                        withAnimation {
                            vm.step = .name
                        }
                    case .password:
                        vm.direction = -1
                        withAnimation {
                            vm.step = .username
                        }
                    case .referral:
                        vm.direction = -1
                        withAnimation {
                            vm.step = .password
                        }
                    case .tos:
                        vm.direction = -1
                        withAnimation {
                            vm.step = .referral
                        }
                    }
                }
                
                CButton(fullWidth: true, size: .lg, variant: .primary, text: vm.step.nextButtonTitle, isLoading: !vm.loadingSections.isEmpty) {
                    guard vm.isValid else { return }
                    
                    vm.direction = 1
                    
                    switch vm.step {
                    case .email:
                        withAnimation {
                            vm.step = .name
                        }
                    case .name:
                        withAnimation {
                            vm.step = .username
                        }
                    case .username:
                        withAnimation {
                            vm.step = .password
                        }
                    case .password:
                        withAnimation {
                            vm.step = .referral
                        }
                    case .referral:
                        withAnimation {
                            vm.step = .tos
                        }
                    case .tos:
                        Task {
                            await vm.submit()
                        }
                    }
                }
                .disabled(!vm.loadingSections.isEmpty || !vm.isValid)
            }
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
    }
    
    private var emailView: some View {
        ScrollView {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Create an account")
                            .cfont(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom)
                        Text("Sign up to explore, socialize, and review thousands of dining spots!")
                            .fixedSize(horizontal: false, vertical: true)
                            .cfont(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
                    
                    Image(.ghost)
                }
                .padding(.bottom)
                
                TextField("Email", text: $vm.email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .cfont(.title2)
                    .keyboardType(.emailAddress)
                    .textContentType(UITextContentType.emailAddress)
                    .focused($focusedField, equals: .email)
                    .padding(.bottom, 20)
                    .overlay(alignment: .bottom) {
                        if !vm.email.isEmpty && !vm.isValidEmail {
                            Text("Invalid email address")
                                .cfont(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                
                Text("In the digital realm, pigeons are passé. We use emails. Yours, please?")
                    .fixedSize(horizontal: false, vertical: true)
                    .cfont(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, mainWindowSize.height / 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if focusedField != nil || !vm.isValidEmail {
                focusedField = .email
            }
        }
    }
    
    private var nameView: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Image(.thinking)
                    Text("What's your name")
                        .cfont(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 3)
                    Text("Imagine a cheering crowd after your epic achievement. What name are they chanting?")
                        .fixedSize(horizontal: false, vertical: true)
                        .cfont(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                TextField("Full Name", text: $vm.name)
                    .cfont(.title2)
                    .keyboardType(.namePhonePad)
                    .focused($focusedField, equals: .name)
                    .textContentType(.name)
            }
            .padding(.top, mainWindowSize.height / 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if focusedField != nil || vm.name.isEmpty {
                focusedField = .name
            }
        }
    }
    
    private var usernameView: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Image(.cool)
                    Text("Choose a username")
                        .cfont(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 3)
                    Text("Craft a username as iconic as your latest dance move")
                        .fixedSize(horizontal: false, vertical: true)
                        .cfont(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                TextField("Username", text: $vm.username)
                    .cfont(.title2)
                    .keyboardType(.default)
                    .autocorrectionDisabled(true)
                    .focused($focusedField, equals: .username)
                    .overlay(
                        HStack {
                            if vm.username.count > 0 {
                                Group {
                                    if vm.loadingSections.contains(.username) {
                                        ProgressView()
                                    } else if vm.isUsernameValid {
                                        Image(systemName: "checkmark").foregroundColor(.green)
                                    } else {
                                        Image(systemName: "xmark").foregroundColor(.red)
                                    }
                                }
                                .transition(AnyTransition.opacity.animation(.easeIn))
                            }
                        },
                        alignment: .trailing
                    )
                
                if vm.username.count > 0, let error = vm.usernameError, !vm.isUsernameValid {
                    Text(error)
                        .foregroundStyle(.red)
                        .cfont(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(AnyTransition.opacity.animation(.easeIn))
                }
            }
            .padding(.top, mainWindowSize.height / 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if focusedField != nil || !(vm.username.count > 5 && vm.isUsernameValid) {
                focusedField = .username
            }
        }
    }
    
    private var passwordView: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Image(.lock)
                    Text("Choose a password")
                        .cfont(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 3)
                    Text("Tip: Something memorable but not 'password123' memorable.")
                        .fixedSize(horizontal: false, vertical: true)
                        .cfont(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                SecureField("Password", text: $vm.password)
                    .cfont(.title2)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
            }
            .padding(.top, mainWindowSize.height / 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if focusedField != nil || vm.password.count < 5 {
                focusedField = .password
            }
        }
    }
    
    private var referralView: some View {
        ScrollView {
            VStack {
                if !vm.suggestedUsersList.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            Spacer()
                            ForEach(vm.suggestedUsersList) { user in
                                Button {
                                    withAnimation {
                                        vm.referredBy = user
                                        vm.suggestedUsersList.removeAll()
                                    }
                                } label: {
                                    HStack {
                                        ProfileImage(user.profileImage, size: 32, cornerRadius: 10)
                                        
                                        VStack(alignment: .leading) {
                                            Group {
                                                if user.verified {
                                                    HStack {
                                                        Text(user.name)
                                                        Image(systemName: "checkmark.seal")
                                                            .font(.system(size: 14))
                                                            .foregroundStyle(.blue)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                } else {
                                                    Text(user.name)
                                                        .cfont(.body)
                                                    
                                                }
                                            }
                                            .cfont(.body)
                                            .fontWeight(.semibold)
                                            
                                            Text("@\(user.username)")
                                                .cfont(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .frame(height: 46)
                                    .background(Color.themePrimary)
                                }
                                .foregroundStyle(.primary)
                                
                                Divider()
                            }
                        }
                        .frame(height: max(48 * 4, Double(vm.suggestedUsersList.count) * 48))
                    }
                    .scrollIndicators(.hidden)
                    .frame(height: 48 * 4)
                } else {
                    VStack(alignment: .leading) {
                        Image(.friends)
                        Text("Joining Us Through a Friend?")
                            .cfont(.title2)
                            .fontWeight(.semibold)
                            .padding(.bottom, 3)
                        Text("Got a friend here? Enter their username and unlock rewards! (Optional)")
                            .fixedSize(horizontal: false, vertical: true)
                            .cfont(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                }
                
                if let referredBy = vm.referredBy {
                    HStack {
                        ProfileImage(referredBy.profileImage, size: 52, cornerRadius: 10)
                        
                        VStack(alignment: .leading) {
                            Text(referredBy.name)
                                .cfont(.title3)
                                .fontWeight(.semibold)
                            Text("@\(referredBy.username)")
                                .foregroundStyle(.secondary)
                                .cfont(.caption)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                vm.referredBy = nil
                                vm.showPasteButton = false
                                self.referredBy = ""
                                focusedField = .userSearch
                            }
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                } else if vm.showPasteButton && referredBy.isEmpty {
                    HStack {
                        Text("Tap 'Paste' to apply your referral link automatically after copying it.")
                            .cfont(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PasteButton(supportedContentTypes: [.url]) { itemProviders in
                            Branch.getInstance().passPaste(itemProviders)
                            vm.showPasteButton = false
                        }
                    }
                } else if !referredBy.isEmpty {
                    HStack {
                        ProfileImage(nil, size: 52, cornerRadius: 10)
                            .redacted(reason: .placeholder)
                        
                        VStack(alignment: .leading) {
                            Text("Name")
                                .cfont(.title3)
                                .fontWeight(.semibold)
                            Text("@username")
                                .foregroundStyle(.secondary)
                                .cfont(.caption)
                        }
                        .redacted(reason: .placeholder)
                        
                        Spacer()
                        
                        ProgressView()
                    }
                    .task {
                        await vm.getRefferedBy(id: referredBy)
                    }
                } else {
                    TextField("Search Your Friend...", text: $vm.userSearch)
                        .cfont(.title2)
                        .keyboardType(.default)
                        .autocorrectionDisabled(true)
                        .focused($focusedField, equals: .userSearch)
                        .onAppear {
                            if focusedField != nil {
                                focusedField = .userSearch
                            }
                        }
                }
            }
            .padding(.top, mainWindowSize.height / 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .top)
    }
    
    private var tosView: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Image(.handshake)
                    Text("Last Step")
                        .cfont(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 3)
                    Text("One tiny hurdle before the fun begins! Let's leap over the legal bit.")
                        .cfont(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                Toggle(isOn: $vm.eula) {
                    VStack(alignment: .leading) {
                        Text("I have read and agree to the")
                        Link("End User License Agreement", destination: URL(string: "\(K.ENV.WebsiteURL)/eula")!)
                        HStack {
                            Text("and")
                            Link("Privacy Policy", destination: URL(string: "\(K.ENV.WebsiteURL)/privacy-policy")!)
                        }
                    }
                    .cfont(.body)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    SignUpWithPasswordView()
}
