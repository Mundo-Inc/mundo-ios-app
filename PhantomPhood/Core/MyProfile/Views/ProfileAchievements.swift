//
//  ProfileAchievements.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct ProfileAchievements: View {
    @ObservedObject private var auth = Authentication.shared
    
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 80, maximum: 200)),
        GridItem(.flexible(minimum: 80, maximum: 200), spacing: 10, alignment: .top),
        GridItem(.flexible(minimum: 80, maximum: 200))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            if let currentUser = auth.currentUser {
                ForEach(AchievementsManager.list) { item in
                    Achievement(achievement: item, recievedAchievements: currentUser.progress.achievements)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ProfileAchievements()
}
