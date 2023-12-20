//
//  Achievement.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct Achievement: View {
    let achievement: AchievementsManager.Achievement
    
    let count: Int
    let date: String?
    
    init(achievement: AchievementsManager.Achievement, recievedAchievements: [UserAchievments]) {
        self.achievement = achievement
        
        let same = recievedAchievements.filter { $0.type == achievement.id }
        
        if let last = same.last {
            count = same.count
            date = last.createdAt
        } else {
            self.count = 0
            self.date = nil
        }
    }
    
    var body: some View {
        VStack {
            if count == 0 {
                Image(.LOCKED)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(achievement.id)
                    .resizable()
                    .scaledToFit()
            }
            
            Text((count > 1 ? "\(count)x " : "") + achievement.title)
                .multilineTextAlignment(.center)
                .font(.custom(style: .subheadline))
                .foregroundStyle(.primary)
                .opacity(0.85)
            
            Text(achievement.description)
                .multilineTextAlignment(.center)
                .font(.custom(style: .caption))
                .foregroundStyle(.secondary)
            
            if let date, let theDate = DateFormatter.stringToDate(dateString: date) {
                Text(DateFormatter.dateToShortString(date: theDate))
                    .font(.custom(style: .caption))
                    .foregroundStyle(.tertiary)
            } else {
                Text("LOCKED")
                    .font(.custom(style: .caption))
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    Achievement(achievement: .init(id: "LEGEND", title: "Legend Badge", description: "Reach level 100"), recievedAchievements: [.init(_id: "", type: "LEGEND", createdAt: "2023-10-25T02:02:15.389Z")])
}
