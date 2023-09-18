//
//  ProfileStats.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 16.09.2023.
//

import SwiftUI

struct ProfileStats: View {
    @EnvironmentObject private var auth: Authentication
    
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Social")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
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
                        value: auth.user?.followersCount
                    )

                    Spacer()
                    
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
                        title: "Followings",
                        value: auth.user?.followingCount
                    )
                }
            }
                        
            VStack {
                Text("Level & Rankings")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 20) {
                    LevelView(level: .convert(level: auth.user?.level ?? 0))
                    
                    VStack {
                        Text("To next level")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ProgressView(value: 0.4)
                            .foregroundStyle(.secondary)
                            .progressViewStyle(.linear)
                            
                        
                        HStack(spacing: 0) {
                            Text("1340")
                                .font(.headline)
                                .foregroundStyle(Color.accentColor)
                            Text("/1400")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding(.trailing)
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("Rank")
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                            .bold()
                        Text("#2")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .bold()
                    }
                    
                    
                }.padding(.trailing, 8)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themePrimary)
                .clipShape(.rect(cornerRadius: 15))
            }
            
            
            VStack {
                Text("Activities")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
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
                        value: auth.user?.reviewsCount
                    )
                    
                    Spacer()
                    
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
                        title: "Checkins",
                        value: "Soon"
                    )
                }
            }
            
            Spacer()

            
        }

        .padding()
    }
}

#Preview {
    ProfileStats()
        .environmentObject(Authentication())
}
