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
        GridItem(.flexible(minimum: 100, maximum: 300), spacing: 15),
        GridItem(.flexible(minimum: 100, maximum: 300), spacing: 15)
    ]
    
    var lockedAchievements: [AchievementsEnum] {
        if let currentUser = auth.currentUser {
            let allAchievements = Array(AchievementsEnum.allCases)
            return allAchievements.filter { item in
                return !currentUser.progress.achievements.contains(where: { $0.id == item })
            }
        }
        return []
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.primary.opacity(0.7))
                        .padding(.bottom, 1)
                    
                    if let currentUser = auth.currentUser {
                        Text("\(currentUser.progress.achievements.count)/\(AchievementsEnum.allCases.count)")
                            .font(.custom(style: .title2))
                            .fontWeight(.bold)
                            .foregroundStyle(.primary.opacity(0.7))
                    }
                    
                    Text("Total Achievements Completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.bottom)
            
            LazyVGrid(columns: columns, spacing: 15) {
                if let currentUser = auth.currentUser {
                    if !currentUser.progress.achievements.isEmpty {
                        Section {
                            ForEach(currentUser.progress.achievements) { item in
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
        }
        .padding()
    }
}

#Preview {
    ProfileAchievements()
}
