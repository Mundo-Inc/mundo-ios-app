//
//  SettingsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var auth = Authentication.shared
    @AppStorage("theme") var theme: String = ""
    
    var body: some View {
        List {
            Section(header: Text("Account Information")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Email")
                            .font(.body)
                        if let user = auth.user {
                            HStack(spacing: 2) {
                                Image(systemName: user.email.verified ? "checkmark.seal" : "xmark.square")
                                    .font(.system(size: 14))
                                Text(user.email.verified ? "Verified" : "Not Verified")
                                    .font(.caption)
                            }.foregroundColor(user.email.verified ? .accentColor : .secondary)
                        }
                    }
                    Text(auth.user?.email.address ?? "user@domain.com")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Phone Number")
                            .font(.body)
                    }
                    Text("Not Set")
                        .font(.callout)
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
            Button {
                auth.signout()
            } label: {
                Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }.listStyle(.insetGrouped)
        
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}
