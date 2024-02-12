//
//  AchievementsEnum.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/9/24.
//

import Foundation

enum AchievementsEnum: String, CaseIterable, Codable {
    case ADVENTURER
    case AMBASSADOR
    case BETA_PIONEER
    case CHECK_CHECK
    case CRITIC_ON_THE_RISE
    case CRITIC
    case EARLY_BIRD
    case ELITE
    case EXPLORER
    case INFLUENCER
    case LEGEND
    case MASTEREXPLORER
    case NIGHT_OWL
    case PAPARAZZI_PRO
    case POLL_TAKER
    case QUESTION_MASTER
    case REACT_ROLL
    case ROOKIE_REVIEWER
    case SOCIALITE
    case STARTER
    case WEEKEND_WANDERLUST
    case WORLD_DOMINATOR

    var title: String {
        switch self {
        case .ADVENTURER:
            return "Adventurer Badge"
        case .AMBASSADOR:
            return "Ambassador Badge"
        case .BETA_PIONEER:
            return "Beta Pioneer"
        case .CHECK_CHECK:
            return "Check Check"
        case .CRITIC_ON_THE_RISE:
            return "Critic on the Rise"
        case .CRITIC:
            return "Critic Badge"
        case .EARLY_BIRD:
            return "Early Bird"
        case .ELITE:
            return "Elite Badge"
        case .EXPLORER:
            return "Explorer Badge"
        case .INFLUENCER:
            return "Influencer Badge"
        case .LEGEND:
            return "Legend Badge"
        case .MASTEREXPLORER:
            return "Master Explorer Badge"
        case .NIGHT_OWL:
            return "Night Owl"
        case .PAPARAZZI_PRO:
            return "Paparazzi Pro"
        case .POLL_TAKER:
            return "Poll Taker"
        case .QUESTION_MASTER:
            return "Question Master"
        case .REACT_ROLL:
            return "React & Roll"
        case .ROOKIE_REVIEWER:
            return "Rookie Reviewer"
        case .SOCIALITE:
            return "Socialite Badge"
        case .STARTER:
            return "Starter Badge"
        case .WEEKEND_WANDERLUST:
            return "Weekend Wanderlust"
        case .WORLD_DOMINATOR:
            return "World Dominator"
        }
    }

    var description: String {
        switch self {
        case .ADVENTURER:
            return "Reach level 40"
        case .AMBASSADOR:
            return "Reach level 80"
        case .BETA_PIONEER:
            return "Celebrating our beta community!"
        case .CHECK_CHECK:
            return "Check-in 5 times in a week"
        case .CRITIC_ON_THE_RISE:
            return "10 reviews and counting!"
        case .CRITIC:
            return "Reach level 30"
        case .EARLY_BIRD:
            return "Check into a place before 9 AM"
        case .ELITE:
            return "Reach level 70"
        case .EXPLORER:
            return "Reach level 20"
        case .INFLUENCER:
            return "Reach level 60"
        case .LEGEND:
            return "Reach level 100"
        case .MASTEREXPLORER:
            return "Reach level 90"
        case .NIGHT_OWL:
            return "Check into a place after 10 PM"
        case .PAPARAZZI_PRO:
            return "Add 5 photo-included reviews"
        case .POLL_TAKER:
            return "Participate in a poll!"
        case .QUESTION_MASTER:
            return "Create your first poll!"
        case .REACT_ROLL:
            return "React to 25 different posts!"
        case .ROOKIE_REVIEWER:
            return "Post your first review!"
        case .SOCIALITE:
            return "Reach level 50"
        case .STARTER:
            return "Reach level 10"
        case .WEEKEND_WANDERLUST:
            return "Check into at different places for 4 weekends straight!"
        case .WORLD_DOMINATOR:
            return "Conquering the global leaderboard!"
        }
    }
}
