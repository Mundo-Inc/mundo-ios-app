//
//  LeaderboardView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var appData: AppData
    
    var body: some View {
        NavigationStack(path: $appData.leaderboardNavStack) {
            VStack {
                Text("Leaderboard Items")
            }
            .navigationTitle("Leaderboard")
            .navigationDestination(for: LeaderboardStack.self) { link in
                switch link {
                case .userProfile(let id):
                    UserProfileView(id: id)
                }
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .environmentObject(AppData())
    }
}
