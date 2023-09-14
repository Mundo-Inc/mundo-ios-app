//
//  PhantomPhoodApp.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI

@main
struct PhantomPhoodApp: App {
   @StateObject var auth = Authentication()
    
    var body: some Scene {
        WindowGroup {

            Group {
                if auth.isSignedIn {
                    if let _ = auth.user {
                        ContentView()
                    } else {
                        ProgressView()
                    }
                } else {
                    WelcomeView()
                }
            }.environmentObject(auth)
        }
    }
}
