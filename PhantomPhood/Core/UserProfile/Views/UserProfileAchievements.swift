//
//  UserProfileAchievements.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct UserProfileAchievements: View {
    @Environment(\.mainWindowSize) private var mainWindowSize
    
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
        LazyVGrid(columns: columns, spacing: 15) {
            VStack {
                LevelView(level: user.progress.level)
                    .padding(.all, mainWindowSize.width * 0.06)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("To Next Level".uppercased())
                        .multilineTextAlignment(.leading)
                        .cfont(.subheadline)
                        .foregroundStyle(.primary.opacity(0.4))
                        .fontWeight(.medium)
                    
                    ProgressView(value: user.levelProgress)
                        .foregroundStyle(.secondary)
                        .progressViewStyle(.linear)
                    
                    HStack(spacing: 0) {
                        Text("\(user.progress.xp - user.prevLevelXp)")
                            .foregroundStyle(Color.accentColor)
                            .fontWeight(.bold)
                        Text("/\(user.progress.xp + user.remainingXp - user.prevLevelXp)")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .cfont(.footnote)
                }
            }
            .padding(.all, 10)
            .background(LinearGradient(colors: [
                Color(hue: 346 / 360, saturation: 0.84, brightness: 0.22),
                Color(hue: 346 / 360, saturation: 0.7, brightness: 0.4)
            ], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.4), style: .init(lineWidth: 3))
                    .shadow(color: Color.black.opacity(0.3), radius: 5)
                    .padding(.all, 1)
            }
            
            VStack {
                ZStack {
                    Text("#\(user.rank)")
                        .font(.custom(K.Fonts.satoshi, fixedSize: 48))
                        .minimumScaleFactor(0.5)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hue: 329 / 360, saturation: 0.49, brightness: 1).opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Text("GLOBAL\nRANKING")
                    .multilineTextAlignment(.center)
                    .cfont(.subheadline)
                    .foregroundStyle(.primary.opacity(0.4))
                    .fontWeight(.medium)
            }
            .padding(.all, 10)
            .background(LinearGradient(colors: [
                Color(hue: 274 / 360, saturation: 0.74, brightness: 0.46),
                Color(hue: 0, saturation: 0.75, brightness: 0.57)
            ], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.4), style: .init(lineWidth: 3))
                    .shadow(color: Color.black.opacity(0.3), radius: 5)
                    .padding(.all, 1)
            }
            .onTapGesture {
                AppData.shared.goTo(.leaderboard)
            }
            
            if !user.progress.achievements.isEmpty {
                Section {
                    ForEach(user.progress.achievements) { item in
                        Achievement(data: item)
                    }
                } header: {
                    HStack(spacing: 0) {
                        Text("Earned Badges".uppercased())
                            .cfont(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fontWeight(.semibold)
                        
                        Text("\(user.progress.achievements.count)")
                            .cfont(.headline)
                            .foregroundStyle(.secondary)
                        Text("/\(AchievementsEnum.allCases.count)")
                            .cfont(.headline)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            Section {
                ForEach(lockedAchievements, id: \.self) { achievement in
                    Achievement(achievement: achievement)
                }
            } header: {
                Text("Locked".uppercased())
                    .cfont(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .padding(.bottom, 30)
    }
}
