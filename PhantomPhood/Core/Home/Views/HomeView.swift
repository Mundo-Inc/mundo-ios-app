//
//  HomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var auth: Authentication
    @EnvironmentObject private var appData: AppData
    
    var body: some View {
        NavigationStack(path: $appData.homeNavStack) {
            ScrollView {
                Text("Welcome \(auth.user?.name ?? "")")
                
                ForEach(0..<20, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 25)
                        .frame(height: 100)
                        .foregroundColor(Color.themePrimary)
                }
                
                Button("Sign Out") {
                    auth.signout()
                }.buttonStyle(.bordered)
            }
            .navigationTitle("Feed")
            .navigationDestination(for: HomeStack.self) { link in
                switch link {
                case .notifications:
                    NotificationsView()
                case .place(let id):
                    PlaceView(id: id)
                case .userProfile(let id):
                    UserProfileView(id: id)
                }
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppData())
    }
}
