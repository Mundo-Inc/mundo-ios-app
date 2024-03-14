//
//  UserProfileStats.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/29/23.
//

import SwiftUI

struct UserProfileStats: View {
    let user: UserDetail?
    @Binding var activeTab: UserProfileTab
    
    @ObservedObject var appData = AppData.shared
    
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Social")
                    .font(.custom(style: .headline))
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    NavigationLink(value: AppRoute.userConnections(userId: user?.id ?? "", initTab: .followers)) {
                        DataCard(
                            icon: "person.3.fill",
                            iconColor: LinearGradient(colors: [
                                Color(red: 0.34, green: 0.79, blue: 0.76),
                                Color(red: 0.43, green: 0.6, blue: 0.85)
                            ], startPoint: .top, endPoint: .bottom),
                            iconBackground: LinearGradient(colors: [
                                Color(red: 0.49, green: 0.6, blue: 0.99).opacity(0.2),
                                Color(red: 0.19, green: 1, blue: 0.76).opacity(0.2)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            title: "Followers",
                            value: user?.followersCount
                        )
                    }
                    .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    NavigationLink(value: AppRoute.userConnections(userId: user?.id ?? "", initTab: .followings)) {
                        DataCard(
                            icon: "person.2.fill",
                            iconColor: LinearGradient(colors: [
                                Color(red: 0.97, green: 0.47, blue: 0.98),
                                Color(red: 0.77, green: 0.24, blue: 0.9)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            iconBackground: LinearGradient(colors: [
                                Color(red: 1, green: 0.1, blue: 0.31).opacity(0.15),
                                Color(red: 0.83, green: 0.37, blue: 1).opacity(0.15)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            title: "Following",
                            value: user?.followingCount
                        )
                    }
                    .foregroundStyle(.primary)
                }
            }
            
            VStack {
                Text("Level & Rankings")
                    .font(.custom(style: .headline))
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 10) {
                    LevelView(level: user?.progress.level ?? -1)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .padding(.all, 5)
                    
                    VStack {
                        Text("To next level")
                            .font(.custom(style: .body))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ProgressView(value: user == nil ? 0 : Double(user!.progress.xp) / Double(user!.progress.xp + user!.remainingXp))
                            .foregroundStyle(.secondary)
                            .progressViewStyle(.linear)
                        
                        
                        HStack(spacing: 0) {
                            Text("\(user?.progress.xp ?? 1000)")
                                .foregroundStyle(Color.accentColor)
                            Text("/\(user == nil ? 3000 : user!.progress.xp + user!.remainingXp)")
                                .foregroundStyle(.secondary)
                        }
                        .redacted(reason: user == nil ? .placeholder : [])
                        .font(.custom(style: .body))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding(.trailing)
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("Rank")
                            .foregroundStyle(.tertiary)
                        Text("\(user?.rank ?? 10)")
                            .foregroundStyle(.secondary)
                            .redacted(reason: user == nil ? .placeholder : [])
                    }
                    .font(.custom(style: .title3))
                    .bold()
                }
                .padding(.trailing, 8)
                .padding(.all, 8)
                .frame(maxWidth: .infinity)
                .background(Color.themePrimary)
                .clipShape(.rect(cornerRadius: 15))
            }
            
            
            VStack {
                Text("Activities")
                    .font(.custom(style: .headline))
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    NavigationLink(value: AppRoute.userActivities(userId: UserIdEnum.withId(user?.id ?? ""), activityType: .newReview)) {
                        DataCard(
                            icon: "quote.bubble.fill",
                            iconColor: LinearGradient(colors: [
                                Color(red: 0.56, green: 0.92, blue: 0.64),
                                Color(red: 0.56, green: 0.92, blue: 0.64),
                                Color(red: 0.93, green: 0.79, blue: 0.43)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            iconBackground: LinearGradient(colors: [
                                Color(red: 0.55, green: 0.99, blue: 0.48).opacity(0.2),
                                Color(red: 0.94, green: 1, blue: 0.19).opacity(0.2)
                            ], startPoint: .leading, endPoint: .trailing),
                            title: "Reviews",
                            value: user?.reviewsCount
                        )
                    }
                    .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    NavigationLink(value: AppRoute.userCheckins(userId: UserIdEnum.withId(user?.id ?? ""))) {
                        DataCard(
                            icon: "mappin.and.ellipse",
                            iconColor: LinearGradient(colors: [
                                Color(red: 1, green: 0.75, blue: 0.1),
                                Color(red: 1, green: 0.25, blue: 0.5)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            iconBackground: LinearGradient(colors: [
                                Color(red: 1, green: 0.75, blue: 0.1).opacity(0.15),
                                Color(red: 1, green: 0.25, blue: 0.5).opacity(0.15)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            title: "Check-ins",
                            value: user?.totalCheckins
                        )
                    }
                    .foregroundStyle(.primary)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    UserProfileStats(user: nil, activeTab: .constant(.stats))
}
