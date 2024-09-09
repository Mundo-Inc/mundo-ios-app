//
//  SettingsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var auth = Authentication.shared
    @EnvironmentObject private var alertManager: AlertManager
    
    @AppStorage(K.UserDefaults.theme) private var theme: String = ""
    
    @StateObject private var vm = SettingsVM()
    
    var body: some View {
        List {
            Section(header: Text("Account Information")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Email")
                            .cfont(.body)
                        if let user = auth.currentUser {
                            HStack(spacing: 2) {
                                Image(systemName: user.email.verified ? "checkmark.seal" : "xmark.square")
                                    .font(.system(size: 14))
                                Text(user.email.verified ? "Verified" : "Not Verified")
                                    .cfont(.caption)
                            }
                            .foregroundColor(user.email.verified ? .accentColor : .secondary)
                        }
                    }
                    
                    Text(auth.currentUser?.email.address ?? "user@domain.com")
                        .cfont(.callout)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Phone Number")
                            .cfont(.body)
                    }
                    Text("Not Set")
                        .cfont(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section(header: Text("Privacy")) {
                Toggle(isOn: Binding(get: {
                    auth.currentUser?.isPrivate ?? false
                }, set: { value in
                    Task {
                        await vm.setAccountPrivacy(to: value)
                    }
                })) {
                    Text("Private Account")
                }
                .disabled(vm.loadingSections.contains(.accountPrivacyRequest))
            }
            
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $theme) {
                    Text("System").tag("")
                    Text("Dark").tag("dark")
                    Text("Light").tag("light")
                }
                .frame(maxHeight: 36)
            }
            
            Section(header: Text("Payments")) {
                NavigationLink(value: AppRoute.paymentsSetting) {
                    Label("Payments Setting", systemImage: "creditcard")
                }
            }
            
            if let user = auth.currentUser, user.role == .admin {
                Section {
                    Toggle(isOn: UserSettings.shared.$isBetaTester) {
                        Text("Beta Features")
                    }
                } header: {
                    Label {
                        Text("Admin")
                    } icon: {
                        Image(.Logo.tpLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                    }
                }
            }
            
            Button {
                Task {
                    await auth.signOut()
                }
            } label: {
                Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            
            accountSection
            
            advancedSection
            
            VStack(alignment: .leading) {
                Text("\(K.appName) Inc.")
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Text("App version: " + appVersion)
                }
            }
            .cfont(.caption)
            .foregroundStyle(Color.secondary)
            .listRowBackground(Color.clear)
        }
        .cfont(.body)
        .listStyle(.sidebar)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var accountSection: some View {
        CollapsableSection(isExpanded: $vm.isAccountSettingsVisible, title: "Account") {
            let isLoading = vm.loadingSections.contains(.resetPassword)
            
            Button {
                Task {
                    await vm.resetPasswordRequest()
                }
            } label: {
                Label(
                    title: { Text("Change Password") },
                    icon: { Image(systemName: "ellipsis.rectangle.fill") }
                )
            }
            .foregroundStyle(Color.primary)
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
            
            Button(role: .destructive) {
                alertManager.value = .init(message: "Are you sure you want to delete your account? This action is irreversible", confirmationText: "Delete", role: .destructive, callback: {
                    Task {
                        await vm.deleteAccount()
                    }
                })
            } label: {
                Label("Delete Account", systemImage: "person.slash.fill")
            }
            .foregroundStyle(Color.red)
        }
    }
    
    @ViewBuilder
    private var advancedSection: some View {
        CollapsableSection(isExpanded: $vm.isAdvancedSettingsVisible, title: "Advanced") {
            Button(role: .destructive) {
                alertManager.value = .init(message: "Are you sure you want to delete local data?", confirmationText: "Delete", role: .destructive, callback: {
                    DataStack.shared.viewContext.perform {
                        DataStack.shared.deleteAll()
                    }
                })
            } label: {
                Label("Delete Local Data", systemImage: "iphone.gen3.slash")
            }
            .foregroundStyle(Color.red)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ActionManager())
}
