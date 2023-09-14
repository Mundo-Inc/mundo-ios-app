//
//  AppView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 13.09.2023.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var auth: Authentication
    
    var body: some View {
        VStack {
            Text("Welcome \(auth.user?.name ?? "Hey")")
            Button("Sign Out") {
                auth.signout()
            }.buttonStyle(.bordered)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
