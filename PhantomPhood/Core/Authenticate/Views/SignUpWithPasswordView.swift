//
//  LoginScreen.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI
import Combine
import BranchSDK

@MainActor
class SignUpWithPasswordVM: ObservableObject {
    private let checksDM = ChecksDM()
    private let searchDM = SearchDM()
    private let userProfileDM = UserProfileDM()
    
    private var auth = Authentication.shared
    
    enum LoadingSection: Hashable {
        case username
        case userSearch
        case getReferredBy
        case submit
    }
    
    @Published var step = 0
    @Published var direction = 1
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var eula = false
    
    @Published var email: String = ""
    @Published var isValidEmail: Bool = false
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var isUsernameValid: Bool = false
    @Published var usernameError: String? = nil
    @Published var password: String = ""
    
    @Published var error: String?
    
    @Published var showPasteButton = UIPasteboard.general.hasURLs
    @Published var referredBy: UserEssentials? = nil
    
    @Published var suggestedUsersList: [UserEssentials] = []
    @Published var userSearch: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $username
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                if value.count < 5 {
                    if value.count > 0 {
                        self?.usernameError = "Username must be at least 5 characters"
                    }
                    self?.isUsernameValid = false
                    return
                }
                Task {
                    self?.loadingSections.insert(.username)
                    do {
                        try await self?.checksDM.checkUsername(value)
                        self?.isUsernameValid = true
                    } catch let error as APIManager.APIError {
                        self?.isUsernameValid = false
                        switch error {
                        case .serverError(let serverError):
                            self?.usernameError = serverError.message
                        default:
                            self?.usernameError = "Unknown Error"
                        }
                    }
                    self?.loadingSections.remove(.username)
                }
            }
            .store(in: &cancellables)
        
        $userSearch
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                guard value.count >= 3 else { return }
                
                Task {
                    await self?.searchUsers(q: value)
                }
            }
            .store(in: &cancellables)
    }
    
    func searchUsers(q: String) async {
        self.loadingSections.insert(.userSearch)
        do {
            let users = try await searchDM.searchUsers(q: q)
            withAnimation {
                self.suggestedUsersList = users
            }
        } catch {
            print(error)
        }
        self.loadingSections.remove(.userSearch)
    }
    
    func getRefferedBy(id: String) async {
        self.loadingSections.insert(.getReferredBy)
        do {
            let user = try await userProfileDM.getUserEssentials(id: id)
            withAnimation {
                self.referredBy = user
            }
        } catch {
            print(error)
        }
        self.loadingSections.remove(.getReferredBy)
    }
    
    func submit() async {
        loadingSections.insert(.submit)
        do {
            try await auth.signUp(name: name, email: email, password: password, username: username.count >= 5 ? username : nil, referrer: referredBy?.id)
        } catch APIManager.APIError.serverError(let serverError) {
            withAnimation {
                self.error = serverError.message
            }
        } catch {
            withAnimation {
                self.error = error.localizedDescription
            }
        }
        self.loadingSections.remove(.submit)
    }
}

// MARK: - View

struct SignUpWithPasswordView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var auth = Authentication.shared
    @StateObject private var vm = SignUpWithPasswordVM()
    
    enum Field: Hashable {
        case email
        case name
        case username
        case password
        case userSearch
    }
    
    @FocusState private var focusedField: Field?
    
    @AppStorage(UserSettings.Keys.referredBy.rawValue) var referredBy: String = ""
    
    var body: some View {
        VStack {
            if let error = vm.error {
                Text(error)
                    .font(.custom(style: .headline))
                    .foregroundColor(.red)
                    .onTapGesture {
                        vm.error = nil
                    }
                    .transition(AnyTransition.scale.combined(with: .opacity).animation(.easeInOut))
            }
            Group {
                switch vm.step {
                case 0:
                    VStack {
                        Spacer()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Create an account")
                                    .font(.custom(style: .title2))
                                    .fontWeight(.semibold)
                                    .padding(.bottom)
                                Text("Sign up to explore, socialize, and review thousands of dining spots!")
                                    .font(.custom(style: .subheadline))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }.frame(minHeight: 140)
                            
                            Spacer()
                            
                            Image(.ghost)
                        }
                        .padding(.bottom)
                        
                        TextField("Email", text: $vm.email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .font(.custom(style: .title2))
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
                                .font(.custom(style: .caption))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text("In the digital realm, pigeons are passé. We use emails. Yours, please?")
                            .font(.custom(style: .caption))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        Spacer()
                    }
                    .onAppear {
                        if vm.email.count < 3 {
                            focusedField = .email
                        }
                    }
                    
                case 1:
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Image(.thinking)
                            Text("What's your name")
                                .font(.custom(style: .title2))
                                .fontWeight(.semibold)
                                .padding(.bottom, 3)
                            Text("Imagine a cheering crowd after your epic achievement. What name are they chanting?")
                                .font(.custom(style: .subheadline))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        
                        TextField("Full Name", text: $vm.name)
                            .font(.custom(style: .title2))
                            .keyboardType(.namePhonePad)
                            .focused($focusedField, equals: .name)
                            .textContentType(.name)
                        
                        Spacer()
                        Spacer()
                    }
                    .onAppear {
                        if vm.name.count < 1 {
                            focusedField = .name
                        }
                    }
                    
                case 2:
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Image(.cool)
                            Text("Choose a username")
                                .font(.custom(style: .title2))
                                .fontWeight(.semibold)
                                .padding(.bottom, 3)
                            Text("Craft a username as iconic as your latest dance move")
                                .font(.custom(style: .subheadline))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        
                        TextField("Username", text: $vm.username)
                            .font(.custom(style: .title2))
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
                                        .transition(AnyTransition.opacity.animation(.spring))
                                    }
                                },
                                alignment: .trailing
                            )
                        
                        if vm.username.count > 0, let error = vm.usernameError, !vm.isUsernameValid {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(AnyTransition.opacity.animation(.spring))
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    .onAppear {
                        if !(vm.username.count > 5 && vm.isUsernameValid) {
                            focusedField = .username
                        }
                    }
                    
                case 3:
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Image(.lock)
                            Text("Choose a password")
                                .font(.custom(style: .title2))
                                .fontWeight(.semibold)
                                .padding(.bottom, 3)
                            Text("Tip: Something memorable but not 'password123' memorable.")
                                .font(.custom(style: .subheadline))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        
                        SecureField("Password", text: $vm.password)
                            .font(.custom(style: .title2))
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                        
                        Spacer()
                        Spacer()
                    }
                    .onAppear {
                        if vm.password.count < 5 {
                            focusedField = .password
                        }
                    }
                    
                case 4:
                    VStack {
                        Spacer()
                        
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
                                                                .font(.custom(style: .body))
                                                            
                                                        }
                                                    }
                                                    .font(.custom(style: .body))
                                                    .fontWeight(.semibold)
                                                    
                                                    Text("@\(user.username)")
                                                        .font(.custom(style: .caption))
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
                                    .font(.custom(style: .title2))
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 3)
                                Text("Got a friend here? Enter their username and unlock rewards!")
                                    .font(.custom(style: .subheadline))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                Text("(Optional)")
                                    .font(.custom(style: .subheadline))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom)
                        }
                        
                        if let referredBy = vm.referredBy {
                            HStack {
                                ProfileImage(referredBy.profileImage, size: 52, cornerRadius: 10)
                                
                                VStack(alignment: .leading) {
                                    Text(referredBy.name)
                                        .font(.custom(style: .title3))
                                        .fontWeight(.semibold)
                                    Text("@\(referredBy.username)")
                                        .foregroundStyle(.secondary)
                                        .font(.custom(style: .caption))
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
                                    .font(.custom(style: .caption2))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                PasteButton(supportedContentTypes: [.url]) { itemProviders in
                                    Branch.getInstance().passPaste(itemProviders)
                                    vm.showPasteButton = false
                                }
                            }
                        } else if !referredBy.isEmpty {
                            HStack {
                                ProfileImage("", size: 52, cornerRadius: 10)
                                    .redacted(reason: .placeholder)
                                
                                VStack(alignment: .leading) {
                                    Text("Name")
                                        .font(.custom(style: .title3))
                                        .fontWeight(.semibold)
                                    Text("@username")
                                        .foregroundStyle(.secondary)
                                        .font(.custom(style: .caption))
                                }
                                .redacted(reason: .placeholder)
                                
                                Spacer()
                                
                                ProgressView()
                            }
                            .onAppear {
                                Task {
                                    await vm.getRefferedBy(id: referredBy)
                                }
                            }
                        } else {
                            TextField("Search Your Friend...", text: $vm.userSearch)
                                .font(.custom(style: .title2))
                                .keyboardType(.default)
                                .autocorrectionDisabled(true)
                                .focused($focusedField, equals: .userSearch)
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    
                case 5:
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Image(.handshake)
                            Text("Last Step")
                                .font(.custom(style: .title2))
                                .fontWeight(.semibold)
                                .padding(.bottom, 3)
                            Text("One tiny hurdle before the fun begins! Let's leap over the legal bit.")
                                .font(.custom(style: .subheadline))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        
                        Toggle(isOn: $vm.eula) {
                            VStack(alignment: .leading) {
                                Text("I have read and agree to the")
                                Link("End User License Agreement", destination: URL(string: "https://phantomphood.ai/eula")!)
                                HStack {
                                    Text("and")
                                    Link("Privacy Policy", destination: URL(string: "https://phantomphood.ai/privacy-policy")!)
                                }
                            }
                            .font(.custom(style: .body))
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    
                default:
                    Text("Error")
                        .font(.custom(style: .body))
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .transition(
                .asymmetric(
                    insertion: .move(edge: vm.direction == 1 ? .trailing : .leading),
                    removal: .move(edge: vm.direction == 1 ? .leading : .trailing))
            )
            .animation(.spring(), value: vm.step)
            
            Spacer()
            HStack {
                Button {
                    if (vm.step > 0) {
                        vm.direction = -1
                        withAnimation {
                            vm.step -= 1
                        }
                    } else {
                        vm.direction = 1
                        dismiss()
                    }
                } label: {
                    Text(vm.step == 0 ? "Cancel" : "Back")
                        .font(.custom(style: .subheadline))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderless)
                .controlSize(.large)
                
                Button {
                    var proceed = true
                    switch vm.step {
                    case 0:
                        if !vm.isValidEmail {
                            proceed = false
                        }
                    case 2:
                        if !vm.isUsernameValid {
                            proceed = false
                        }
                    case 3:
                        if vm.password.count < 5 {
                            proceed = false
                        } else {
                            focusedField = nil
                        }
                    case 5:
                        if !vm.eula {
                            proceed = false
                        }
                    default:
                        proceed = true
                    }
                    
                    if (proceed) {
                        if vm.step == 5 {
                            // sign up
                            Task {
                                await vm.submit()
                            }
                        } else {
                            vm.direction = 1
                            withAnimation {
                                vm.step += 1
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        if !vm.loadingSections.isEmpty {
                            ProgressView()
                                .transition(AnyTransition.scale.combined(with: .opacity).animation(.spring))
                                .controlSize(.regular)
                        }
                        Text(vm.step == 5 ? "Sign Up" : "Next")
                    }
                    .animation(.easeInOut, value: vm.loadingSections.isEmpty)
                    .font(.custom(style: .subheadline))
                    .frame(maxWidth: .infinity)
                }
                .transition(AnyTransition.scale.combined(with: .opacity).animation(.spring))
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(
                    !vm.loadingSections.isEmpty ||
                    (
                        vm.step == 0 ? (vm.email.count == 0 || !vm.isValidEmail) :
                            vm.step == 2 ? !vm.isUsernameValid :
                            vm.step == 3 ? vm.password.count < 5 :
                            vm.step == 5 ? !vm.eula : false
                    )
                    
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("HangingPhantom")
                .resizable()
                .frame(width: 100, height: 191)
                .padding(.trailing)
                .ignoresSafeArea(),
            alignment: .topTrailing
        )
    }
}


#Preview {
    SignUpWithPasswordView()
}
