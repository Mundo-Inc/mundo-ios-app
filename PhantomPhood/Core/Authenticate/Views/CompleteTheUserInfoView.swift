//
//  CompleteTheUserInfoView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/23/23.
//

import SwiftUI
import Combine
import BranchSDK

struct CompleteTheUserInfoView: View {
    enum Field: Hashable {
//        case phone
//        case phoneVerification
        case name
        case username
        case userSearch
    }
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    @AppStorage(K.UserDefaults.referredBy) private var referredBy: String = ""
    
    @ObservedObject private var auth = Authentication.shared
    @StateObject private var vm = CompleteTheUserInfoVM()
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack {
            Group {
                switch vm.step {
//                case .phone where auth.currentUser?.phone?.verified != true:
//                    phoneView
//                        .tag(CompleteTheUserInfoVM.Step.phone)
//                case .phoneVerification where auth.currentUser?.phone?.verified != true:
//                    phoneVerificationView
//                        .tag(CompleteTheUserInfoVM.Step.phoneVerification)
                case .name:
                    nameView
                        .tag(CompleteTheUserInfoVM.Step.name)
                case .username:
                    usernameView
                        .tag(CompleteTheUserInfoVM.Step.username)
                case .referral:
                    referralView
                        .tag(CompleteTheUserInfoVM.Step.referral)
                case .tos:
                    tosView
                        .tag(CompleteTheUserInfoVM.Step.tos)
//                default:
//                    Color.clear
//                        .onAppear {
//                            guard let user = auth.currentUser else { return }
//                            guard user.phone?.verified == true else { return }
//                            
//                            withAnimation {
//                                vm.step = .name
//                            }
//                        }
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
                    if auth.currentUser?.acceptedEula == nil {
                        switch vm.step {
//                        case .phone:
//                            Task {
//                                await auth.signOut()
//                                vm.direction = 1
//                            }
//                        case .phoneVerification:
//                            vm.direction = -1
//                            withAnimation {
//                                vm.step = .phone
//                            }
                        case .name:
//                            guard let user = auth.currentUser, user.phone?.verified != true else { return }
//                            
//                            vm.direction = -1
//                            withAnimation {
//                                vm.step = .phoneVerification
//                            }
                            Task {
                                await auth.signOut()
                                vm.direction = 1
                            }
                        case .username:
                            vm.direction = -1
                            withAnimation {
                                vm.step = .name
                            }
                        case .referral:
                            vm.direction = -1
                            withAnimation {
                                vm.step = .username
                            }
                        case .tos:
                            vm.direction = -1
                            withAnimation {
                                vm.step = .referral
                            }
                        }
                    } else {
//                        switch vm.step {
//                        case .phone:
//                            Task {
//                                await auth.signOut()
//                                vm.direction = 1
//                            }
//                        case .phoneVerification:
//                            vm.direction = -1
//                            withAnimation {
//                                vm.step = .phone
//                            }
//                        default:
//                            break
//                        }
                    }
                }
                
                CButton(fullWidth: true, size: .lg, variant: .primary, text: vm.step.nextButtonTitle, isLoading: !vm.loadingSections.isEmpty) {
                    guard vm.isValid else { return }
                    
                    vm.direction = 1
                    
                    switch vm.step {
//                    case .phone:
//                        Task {
//                            withAnimation {
//                                vm.step = .phoneVerification
//                            }
//                            do {
//                                try await vm.sendVerificationCode()
//                            } catch {
//                                vm.error = getErrorMessage(error)
//                                withAnimation {
//                                    vm.step = .phone
//                                }
//                            }
//                        }
//                    case .phoneVerification:
//                        Task {
//                            await vm.verifyPhone()
//                        }
                    case .name:
                        withAnimation {
                            vm.step = .username
                        }
                    case .username:
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
        .onAppear {
            if let user = auth.currentUser {
                if !user.name.isEmpty {
                    vm.name = user.name
                }
                vm.currentUsername = user.username
            }
        }
    }
    
//    private var phoneView: some View {
//        ScrollView {
//            VStack {
//                VStack(alignment: .leading) {
//                    Text("Request for Your Digits")
//                        .cfont(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.bottom)
//                    Text("To continue with the app you need to verify your phone number.")
//                        .fixedSize(horizontal: false, vertical: true)
//                        .cfont(.subheadline)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.leading)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.bottom)
//                
//                HStack(alignment: .bottom) {
//                    Button {
//                        vm.presentedSheet = .countryPicker
//                    } label: {
//                        Text("\(vm.selectedCountry.emoji) \(vm.selectedCountry.dialCode)")
//                            .cfont(.title2)
//                    }
//                    .foregroundStyle(.primary)
//                    .padding(.bottom, 8)
//                    .background(alignment: .bottom) {
//                        RoundedRectangle(cornerRadius: 1)
//                            .frame(height: 2)
//                            .frame(maxWidth: .infinity)
//                            .foregroundStyle(vm.presentedSheet == .countryPicker ? Color.primary.opacity(0.8) : Color.primary.opacity(0.3))
//                    }
//                    
//                    TextField("Phone Number", text: $vm.phoneNumber)
//                        .onChange(of: vm.phoneNumber) { value in
//                            if !value.isEmpty {
//                                let formatted = value.formatPhoneNumber()
//                                
//                                if let country = formatted.country {
//                                    vm.selectedCountry = country
//                                }
//                                
//                                vm.phoneNumber = formatted.number
//                            }
//                        }
//                        .textInputAutocapitalization(.never)
//                        .autocorrectionDisabled(true)
//                        .cfont(.title2)
//                        .keyboardType(.phonePad)
//                        .textContentType(UITextContentType.telephoneNumber)
//                        .focused($focusedField, equals: .phone)
//                        .padding(.bottom, 8)
//                        .background(alignment: .bottom) {
//                            RoundedRectangle(cornerRadius: 1)
//                                .frame(height: 2)
//                                .frame(maxWidth: .infinity)
//                                .foregroundStyle(focusedField == .phone ? Color.primary.opacity(0.8) : Color.primary.opacity(0.3))
//                        }
//                }
//            }
//            .padding(.top, mainWindowSize.height / 5)
//            .padding(.horizontal)
//            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
//        }
//        .scrollIndicators(.hidden)
//        .scrollDismissesKeyboard(.interactively)
//        .ignoresSafeArea(edges: .top)
//        .sheet(item: $vm.presentedSheet) {
//            if vm.phoneNumber.isEmpty {
//                focusedField = .phone
//            }
//        } content: { sheet in
//            switch sheet {
//            case .countryPicker:
//                CountryPickerView(selection: $vm.selectedCountry)
//            }
//        }
//        .onAppear {
//            if focusedField != nil || vm.phoneNumber.isEmpty {
//                focusedField = .phone
//            }
//        }
//    }
//    
//    private var phoneVerificationView: some View {
//        ScrollView {
//            VStack {
//                VStack(alignment: .leading) {
//                    Image(.message)
//                    Text("Please enter the code that\nwe sent you")
//                        .cfont(.title2)
//                        .fontWeight(.semibold)
//                        .padding(.bottom, 3)
//                    Text("Enter the five digit verification code that we’ve sent to your phone")
//                        .cfont(.subheadline)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.leading)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.bottom)
//                
//                Text("C O D E ?")
//                    .foregroundStyle(.tertiary.opacity(vm.phoneVerificationCode.isEmpty ? 0.3 : 0))
//                    .overlay {
//                        TextField("", text: $vm.phoneVerificationCode)
//                            .onChange(of: vm.phoneVerificationCode) { value in
//                                if !value.isEmpty {
//                                    vm.phoneVerificationCode = vm.formatVerificationCode(code: value)
//                                }
//                            }
//                            .frame(maxWidth: .infinity)
//                            .textInputAutocapitalization(.never)
//                            .autocorrectionDisabled(true)
//                            .keyboardType(.numberPad)
//                            .textContentType(UITextContentType.oneTimeCode)
//                            .focused($focusedField, equals: .phoneVerification)
//                    }
//                    .padding(.bottom, 8)
//                    .background(alignment: .bottom) {
//                        Text("_ _ _ _ _")
//                            .foregroundStyle(.tertiary)
//                    }
//                    .padding(.bottom)
//                    .font(.system(size: 32))
//                    .monospaced()
//                
//                Text("Code can take a few minutes (usually seconds) to arrive. Please be patient")
//                    .foregroundStyle(.secondary)
//                    .cfont(.caption2)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(.top, mainWindowSize.height / 5)
//            .padding(.horizontal)
//            .frame(maxWidth: .infinity, minHeight: mainWindowSize.height)
//        }
//        .scrollIndicators(.hidden)
//        .scrollDismissesKeyboard(.interactively)
//        .ignoresSafeArea(edges: .top)
//        .onAppear {
//            if focusedField != nil || vm.phoneVerificationCode.count != 5 {
//                focusedField = .phoneVerification
//            }
//        }
//    }
    
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
            if vm.name.count < 1 {
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
                        .cfont(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
                
                VStack {
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
                                    .transition(AnyTransition.opacity.animation(.spring))
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
                    .cfont(.caption)
                }
                
                if vm.username.count > 0, let error = vm.usernameError, !vm.isUsernameValid {
                    Text(error)
                        .foregroundStyle(.red)
                        .cfont(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(AnyTransition.opacity.animation(.spring))
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
            if !(vm.username.count > 5 && vm.isUsernameValid) {
                focusedField = .username
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
                        Text("Got a friend here? Enter their username and unlock rewards!")
                            .cfont(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        Text("(Optional)")
                            .cfont(.subheadline)
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
    CompleteTheUserInfoView()
}
