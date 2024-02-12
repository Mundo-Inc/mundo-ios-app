//
//  UserProfileAchievements.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct UserProfileAchievements: View {
    let user: UserDetail
    
    let columns: [GridItem] = [
        GridItem(.flexible(minimum: 100, maximum: 300), spacing: 15),
        GridItem(.flexible(minimum: 100, maximum: 300), spacing: 15)
    ]
    
    var lockedAchievements: [AchievementsEnum] {
        let allAchievements = Array(AchievementsEnum.allCases)
        return allAchievements.filter { item in
            return !user.progress.achievements.contains(where: { $0.id == item })
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.system(size: 32))
                        .padding(.bottom, 1)
                        .foregroundStyle(.primary.opacity(0.7))
                    
                    Text("\(user.progress.achievements.count)/\(AchievementsEnum.allCases.count)")
                        .font(.custom(style: .title2))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary.opacity(0.7))
                    
                    Text("Total Achievements Completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.bottom)
            
            LazyVGrid(columns: columns, spacing: 15) {
                if !user.progress.achievements.isEmpty {
                    Section {
                        ForEach(user.progress.achievements) { item in
                            Achievement(data: item)
                        }
                    } header: {
                        Text("Completed".uppercased())
                            .font(.custom(style: .headline))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Section {
                    ForEach(lockedAchievements, id: \.self) { achievement in
                        Achievement(achievement: achievement)
                    }
                } header: {
                    Text("Locked".uppercased())
                        .font(.custom(style: .headline))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
    }
}

//#Preview {
//    UserProfileAchievements(user: .)
//}
