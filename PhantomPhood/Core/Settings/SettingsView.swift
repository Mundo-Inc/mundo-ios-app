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
    
    @AppStorage("theme") private var theme: String = ""
    
    @StateObject private var vm = SettingsVM()
    
    var body: some View {
        List {
            Section(header: Text("Account Information")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Email")
                            .font(.custom(style: .body))
                        if let user = auth.currentUser {
                            HStack(spacing: 2) {
                                Image(systemName: user.email.verified ? "checkmark.seal" : "xmark.square")
                                    .font(.system(size: 14))
                                Text(user.email.verified ? "Verified" : "Not Verified")
                                    .font(.custom(style: .caption))
                            }
                            .foregroundColor(user.email.verified ? .accentColor : .secondary)
                        }
                    }
                    
                    Text(auth.currentUser?.email.address ?? "user@domain.com")
                        .font(.custom(style: .callout))
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Phone Number")
                            .font(.custom(style: .body))
                    }
                    Text("Not Set")
                        .font(.custom(style: .callout))
                        .foregroundStyle(.secondary)
                }
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
            
            if UserSettings.shared.userRole == .admin {
                Section {
                    Toggle(isOn: UserSettings.shared.$isBetaTester) {
                        Text("Beta Features")
                    }
                } header: {
                    Label {
                        Text("Admin")
                    } icon: {
                        Image(.fullPhantom)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 24)
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
            
            Section {
                if vm.isAccountSettingsVisible {
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
                    .foregroundStyle(.primary)
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1)
                    
                    Button(role: .destructive) {
                        alertManager.value = .init(message: "Are you sure you want to delete your account. This action is irreversible", confirmationText: "Delete", role: .destructive, callback: {
                            Task {
                                await vm.deleteAccount()
                            }
                        })
                    } label: {
                        Label("Delete Account", systemImage: "person.slash.fill")
                    }
                }
            } header: {
                Button {
                    withAnimation {
                        vm.isAccountSettingsVisible.toggle()
                    }
                } label: {
                    HStack {
                        Text("Account")
                            .foregroundStyle(Color.secondary)
                        
                        Spacer()
                        
                        Text(vm.isAccountSettingsVisible ? "Hide" : "Show")
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(vm.isAccountSettingsVisible ? 90 : 0))
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text("Phantom Phood Inc.")
                if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Text("App version: " + appVersion)
                }
            }
            .font(.custom(style: .caption))
            .foregroundStyle(Color.secondary)
            .listRowBackground(Color.clear)
        }
        .font(.custom(style: .body))
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ActionManager())
}
