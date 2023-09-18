//
//  HomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: Authentication
    
    var body: some View {
        ScrollView {
            Text("Welcome \(auth.user?.name ?? "")")
            
            ForEach(0..<20, id: \.self) { item in
                RoundedRectangle(cornerRadius: 25)
                    .frame(height: 100)
            }
            
            Button("Sign Out") {
                auth.signout()
            }.buttonStyle(.bordered)
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
