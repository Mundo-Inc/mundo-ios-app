//
//  CompleteTheUserInfoView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/23/23.
//

import SwiftUI
import Combine

@MainActor
class CompleteTheUserInfoVM: ObservableObject {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    private let checksDM = ChecksDM()
    
    @Published var step = 0
    @Published var direction = 1
    
    @Published var isLoading = false
    
    @Published var eula = false
    
    @Published var name: String = ""
    @Published var username: String = ""
    @Published var currentUsername: String = ""
    @Published var isUsernameValid: Bool = false
    @Published var usernameError: String? = nil
    
    @Published var error: String?
    
    private var cancellable = [AnyCancellable]()
    
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
                self?.isLoading = true
                Task {
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
                    self?.isLoading = false
                }
            }
            .store(in: &cancellable)
    }
    
    func saveData() async throws {
        struct EditUserBody: Encodable {
            let name: String?
            let username: String?
            let eula: Bool
        }
        
        if let token = await auth.getToken(), let uid = auth.currentUser?.id {
            let reqBody = try apiManager.createRequestBody(EditUserBody(name: self.name, username: self.username.isEmpty ? nil : self.username, eula: self.eula))
            try await apiManager.requestNoContent("/users/\(uid)", method: .put, body: reqBody, token: token)
            await auth.updateUserInfo()
        }
    }
}

struct CompleteTheUserInfoView: View {
    @ObservedObject private var auth = Authentication.shared
    @StateObject private var vm = CompleteTheUserInfoVM()
    
    enum Field: Hashable {
        case name
        case username
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            if let error = vm.error {
                Text(error)
                    .font(.custom(style: .headline))
                    .foregroundColor(.red)
                    .onTapGesture {
                        vm.error = nil
                    }
            }
            Group {
                switch vm.step {
                case 0:
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Image(.thinking)
                            Text("What's your name")
                                .font(.custom(style: .title2))
                                .fontWeight(.semibold)
                                .padding(.bottom)
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
                    }
                    .onAppear {
                        if vm.name.count < 1 {
                            focusedField = .name
                        }
                    }
                    
                case 1:
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Image(.cool)
                            Text("Choose a username")
                                .font(.custom(style: .title2))
                                .fontWeight(.semibold)
                                .padding(.bottom)
                            Text("Craft a username as iconic as your latest dance move")
                                .font(.custom(style: .subheadline))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        
                        VStack {
                            TextField("Username", text: $vm.username)
                                .font(.custom(style: .title2))
                                .keyboardType(.default)
                                .autocorrectionDisabled(true)
                                .focused($focusedField, equals: .username)
                                .overlay(
                                    HStack {
                                        if vm.username.count > 0 {
                                            if vm.isLoading {
                                                ProgressView()
                                            } else {
                                                vm.isUsernameValid ?
                                                Image(systemName: "checkmark").foregroundColor(.green) :
                                                Image(systemName: "xmark").foregroundColor(.red)
                                            }
                                        }
                                    },
                                    alignment: .trailing
                                )
                            
                            VStack {
                                Text("Your current username:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.secondary)
                                Text(vm.currentUsername)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(Color.accentColor)
                            }
                            .font(.custom(style: .caption))
                        }
                        
                        if vm.username.count > 0, let error = vm.usernameError, !vm.isUsernameValid {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                    }
                    .onAppear {
                        if !(vm.username.count > 5 && vm.isUsernameValid) {
                            focusedField = .username
                        }
                    }
                    
                case 2:
                    VStack {
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Image(.handshake)
                            Text("Last Step")
                                .font(.custom(style: .title2))
                                .fontWeight(.semibold)
                                .padding(.bottom)
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
                        auth.signOut()
                        vm.direction = 1
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
                    case 1:
                        if (!vm.username.isEmpty && !vm.isUsernameValid) {
                            proceed = false
                        }
                    case 2:
                        if !vm.eula {
                            proceed = false
                        }
                    default:
                        proceed = true
                    }
                    
                    if (proceed) {
                        if vm.step == 2 {
                            Task {
                                withAnimation {
                                    vm.isLoading = true
                                }
                                
                                do {
                                    try await vm.saveData()
                                } catch APIManager.APIError.serverError(let serverError) {
                                    withAnimation {
                                        vm.error = serverError.message
                                    }
                                } catch {
                                    withAnimation {
                                        vm.error = error.localizedDescription
                                    }
                                }
                                
                                vm.isLoading = false
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
                        if vm.isLoading {
                            ProgressView()
                                .controlSize(.regular)
                        }
                        Text(vm.step == 2 ? "Finish Sign Up" : "Next")
                    }
                    .font(.custom(style: .subheadline))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(
                    vm.isLoading ||
                    (
                        vm.step == 0 ? vm.name.isEmpty :
                            vm.step == 1 ? (!vm.username.isEmpty && !vm.isUsernameValid) :
                            vm.step == 2 ? !vm.eula : false
                    )
                    
                )
            }
            .padding(.horizontal)
            .padding(.bottom)
            .onAppear {
                if let user = auth.currentUser {
                    if !user.name.isEmpty {
                        vm.name = user.name
                    }
                    vm.currentUsername = user.username
                }
            }
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
    CompleteTheUserInfoView()
}
