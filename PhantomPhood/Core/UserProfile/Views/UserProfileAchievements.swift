//
//  UserProfileAchievements.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct UserProfileAchievements: View {
    let user: UserProfile?
    
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 80, maximum: 200)),
        GridItem(.flexible(minimum: 80, maximum: 200), spacing: 10, alignment: .top),
        GridItem(.flexible(minimum: 80, maximum: 200))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            if let user {
                ForEach(AchievementsManager.list) { item in
                    Achievement(achievement: item, recievedAchievements: user.progress.achievements)
                }
            }
        }
        .padding()
    }
}

#Preview {
    UserProfileAchievements(user: nil)
}
