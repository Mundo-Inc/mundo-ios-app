//
//  Achievement.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct Achievement: View {
    private let data: UserProgress.UserAchievments?
    private let achievement: AchievementsEnum
    
    init(data: UserProgress.UserAchievments) {
        self.achievement = data.id
        self.data = data
    }
    
    init(achievement: AchievementsEnum) {
        self.achievement = achievement
        self.data = nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let data {
                HStack {
                    Text(DateFormatter.dateToShortString(date: data.createdAt))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.tertiary)
                    
                    if data.count > 1 {
                        Text("\(data.count)x")
                            .foregroundStyle(.secondary)
                    }
                }
                .cfont(.caption)
                
                VStack {
                    Image(achievement.rawValue)
                        .resizable()
                        .scaledToFit()
                    
                    Text((data.count > 1 ? "\(data.count)x " : "") + achievement.title)
                        .multilineTextAlignment(.center)
                        .cfont(.subheadline)
                        .foregroundStyle(.primary)
                        .opacity(0.85)
                    
                    Text(achievement.description)
                        .multilineTextAlignment(.center)
                        .cfont(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                VStack {
                    Image(.LOCKED)
                        .resizable()
                        .scaledToFit()
                    
                    Text(achievement.title)
                        .multilineTextAlignment(.center)
                        .cfont(.subheadline)
                        .foregroundStyle(.primary)
                        .opacity(0.85)
                    
                    Text(achievement.description)
                        .multilineTextAlignment(.center)
                        .cfont(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.all, 8)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.themePrimary.gradient.opacity(0.5))
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.themeBorder, style: .init(lineWidth: 3))
            }
            .shadow(color: Color.black.opacity(0.3), radius: 5)
        }
    }
}

#Preview {
    Group {
        Achievement(achievement: .LEGEND)
        Achievement(data: .init(id: .LEGEND, count: 4, createdAt: .now))
    }
}
