//
//  ContentView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11.09.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State private var stackPath: [NavigationModel] = []
    
    @EnvironmentObject var auth: Authentication
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            NavigationStack(path: $stackPath) {
                if let user = auth.user {
                    VStack {
                        Text("Welcome \(user.name)")
                        
                        Button("Sign Out") {
                            auth.signout()
                        }.buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
