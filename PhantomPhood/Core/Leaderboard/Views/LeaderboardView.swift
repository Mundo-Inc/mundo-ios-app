//
//  LeaderboardView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    
    @StateObject private var vm = LeaderboardVM()
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.themeBG.gradient)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ProfileImage(auth.currentUser?.profileImage, size: 64, cornerRadius: 15)
                    
                    VStack(spacing: 8) {
                        Text(auth.currentUser?.name ?? "User Name")
                            .font(.custom(style: .title2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ProgressView(value: auth.currentUser == nil ? 0 : Double(auth.currentUser!.progress.xp) / Double(auth.currentUser!.progress.xp + auth.currentUser!.remainingXp))
                            .foregroundStyle(.secondary)
                            .progressViewStyle(.linear)
                        
                        HStack {
                            Text("\(auth.currentUser?.progress.xp ?? 100) XP")
                                .font(.custom(style: .body))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("#\(auth.currentUser?.rank ?? 10) Global")
                                .font(.custom(style: .body))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .redacted(reason: auth.currentUser == nil ? .placeholder : [])
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LevelView(level: auth.currentUser != nil ? auth.currentUser!.progress.level : -1)
                        .frame(width: 46, height: 54)
                }
                .padding()
                
                Divider()
                
                ScrollViewReader { proxy in
                    Group {
                        if vm.list.isEmpty {
                            List(RepeatItem.create(20)) { item in
                                HStack {
                                    Text("#\(item.index + 1)")
                                        .font(.custom(style: .headline))
                                        .foregroundStyle(item.index == 0 ? Color.gold : item.index == 1 ? Color.silver : item.index == 2 ? Color.bronze : Color.secondary.opacity(0.7))
                                        .frame(minWidth: 40)
                                    
                                    ProfileImage("", size: 38, cornerRadius: 10)
                                        .redacted(reason: .placeholder)
                                    
                                    LevelView(level: 50)
                                        .frame(width: 28, height: 36)
                                        .redacted(reason: .placeholder)
                                    
                                    Text("User name")
                                        .font(.custom(style: .subheadline))
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .redacted(reason: .placeholder)
                                    
                                    Text("9999")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                        .redacted(reason: .placeholder)
                                }
                                .listRowBackground(Color.clear)
                            }
                        } else {
                            List(vm.list.indices, id: \.self) { index in
                                NavigationLink(value: AppRoute.userProfile(userId: vm.list[index].id)) {
                                    HStack {
                                        Text("#\(index + 1)")
                                            .font(.custom(style: .headline))
                                            .foregroundStyle(index == 0 ? Color.gold : index == 1 ? Color.silver : index == 2 ? Color.bronze : Color.secondary.opacity(0.7))
                                            .frame(minWidth: 40)
                                        
                                        ProfileImage(vm.list[index].profileImage, size: 38, cornerRadius: 10)
                                        
                                        LevelView(level: vm.list[index].progress.level)
                                            .frame(width: 28, height: 36)
                                        
                                        Text(vm.list[index].name)
                                            .font(.custom(style: .subheadline))
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("\(vm.list[index].progress.xp)")
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                    }
                                    .onAppear {
                                        if !vm.isLoading {
                                            Task {
                                                await vm.loadMore(index: index)
                                            }
                                        }
                                    }
                                }
                                .foregroundStyle(auth.currentUser?.id == vm.list[index].id ? Color.accentColor : Color.primary)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.visible, edges: .all)
                                .id(index)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await vm.fetchList(.refresh)
                    }
                    .onChange(of: appData.tappedTwice) { tapped in
                        if tapped == .rewardsHub {
                            withAnimation {
                                proxy.scrollTo(1)
                            }
                            appData.tappedTwice = nil
                            Task {
                                await vm.fetchList(.refresh)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Leaderboard")
    }
}

#Preview {
    LeaderboardView()
}
