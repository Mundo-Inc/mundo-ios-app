//
//  AchievementsManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import Foundation

final class AchievementsManager {
    struct Achievement: Identifiable {
        let id: String
        let title: String
        let description: String
    }
    
    static let list: [Achievement] = [
        Achievement(id: "ADVENTURER", title: "Adventurer Badge", description: "Reach level 40"),
        Achievement(id: "AMBASSADOR", title: "Ambassador Badge", description: "Reach level 80"),
        Achievement(id: "BETA_PIONEER", title: "Beta Pioneer", description: "Celebrating our beta community!"),
        Achievement(id: "CHECK_CHECK", title: "Check Check", description: "Check-in 5 times in a week "),
        Achievement(id: "CRITIC_ON_THE_RISE", title: "Critic on the Rise", description: "10 reviews and counting!"),
        Achievement(id: "CRITIC", title: "Critic Badge", description: "Reach level 30"),
        Achievement(id: "EARLY_BIRD", title: "Early Bird", description: "Check into a place before 9 AM"),
        Achievement(id: "ELITE", title: "Elite Badge", description: "Reach level 70"),
        Achievement(id: "EXPLORER", title: "Explorer Badge", description: "Reach level 20"),
        Achievement(id: "INFLUENCER", title: "Influencer Badge", description: "Reach level 60"),
        Achievement(id: "LEGEND", title: "Legend Badge", description: "Reach level 100"),
        Achievement(id: "MASTEREXPLORER", title: "Master Explorer Badge", description: "Reach level 90"),
        Achievement(id: "NIGHT_OWL", title: "Night Owl", description: "Check into a place after 10 PM"),
        Achievement(id: "PAPARAZZI_PRO", title: "Paparazzi Pro", description: "Add 5 photo-included reviews"),
        Achievement(id: "POLL_TAKER", title: "Poll Taker", description: "Participate in a poll!"),
        Achievement(id: "QUESTION_MASTER", title: "Question Master", description: "Create your first poll!"),
        Achievement(id: "REACT_ROLL", title: "React & Roll", description: "React to 25 different posts!"),
        Achievement(id: "ROOKIE_REVIEWER", title: "Rookie Reviewer", description: "Post your first review!"),
        Achievement(id: "SOCIALITE", title: "Socialite Badge", description: "Reach level 50"),
        Achievement(id: "STARTER", title: "Starter Badge", description: "Reach level 10"),
        Achievement(id: "WEEKEND_WANDERLUST", title: "Weekend Wanderlust", description: "Check into at different places for 4 weekends straight!"),
        Achievement(id: "WORLD_DOMINATOR", title: "World Dominator", description: "Conquering the global leaderboard!")
    ]
}
