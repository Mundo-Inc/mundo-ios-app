//
//  SettingsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct SettingsView: View {
    let toastViewModel = ToastViewModel.shared
    let apiManager = APIManager.shared
    
    @ObservedObject private var auth = Authentication.shared
    @AppStorage("theme") var theme: String = ""
    
    @State var showAccountDeleteWarning = false
    func deleteAccount() async {
        do {
            guard let token = await auth.getToken(), let user = auth.currentUser else { return }
                        
            let _ = try await apiManager.requestNoContent("/users/\(user.id)", method: .delete, token: token)
            
            toastViewModel.toast(.init(type: .success, title: "Success", message: "Your account has been deleted"))
            
            auth.signout()
        } catch {
            toastViewModel.toast(.init(type: .error, title: "Something went wrong!", message: "Unable to delete your account"))
            print(error)
        }
    }
    
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
            }
            Section(header: Text("Security")) {
                    Link("Change Password", destination: URL(string: "https://phantomphood.ai/reset-password")!)
            }
            
            Section(header: Text("Account")) {
                Button {
                    showAccountDeleteWarning = true
                } label: {
                    Label("Delete Account", systemImage: "person.slash.fill")
                }
            }
            
            Button {
                auth.signout()
            } label: {
                Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .font(.custom(style: .body))
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .alert("Delete Account", isPresented: $showAccountDeleteWarning) {
            Button(role: .destructive) {
                Task {
                    await deleteAccount()
                }
            } label: {
                Text("Delete")
            }
        } message: {
            Text("Are you sure you want to delete your account. This action is irreversible.")
        }
    }
}

#Preview {
    SettingsView()
}
