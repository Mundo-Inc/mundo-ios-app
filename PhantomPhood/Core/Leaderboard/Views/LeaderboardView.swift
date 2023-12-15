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
        NavigationStack(path: $appData.leaderboardNavStack) {
            ZStack {
                Color.themeBG.ignoresSafeArea()
                
                VStack {
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
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 46, height: 54)
                        
                    }
                    .padding()
                    
                    Divider()
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            Color.clear
                                .frame(width: 0, height: 0)
                                .id(1)
                            
                            LazyVStack {
                                ForEach(vm.list.indices, id: \.self) { index in
                                    NavigationLink(value: LeaderboardStack.userProfile(id: vm.list[index].id)) {
                                        HStack {
                                            Text("#\(index + 1)")
                                                .font(.custom(style: .headline))
                                                .foregroundStyle(.secondary)
                                                .frame(minWidth: 40)
                                            
                                            ProfileImage(vm.list[index].profileImage, size: 36, cornerRadius: 10)
                                            
                                            LevelView(level: vm.list[index].progress.level)
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 28, height: 36)
                                            
                                            Text(vm.list[index].name)
                                                .font(.custom(style: .subheadline))
                                                .bold()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Text("\(vm.list[index].progress.xp)")
                                                .font(.custom(style: .caption))
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.horizontal)
                                        .onAppear {
                                            if !vm.isLoading {
                                                Task {
                                                    await vm.loadMore(currentItem: vm.list[index])
                                                }
                                            }
                                        }
                                    }
                                    .foregroundStyle(auth.currentUser?.id == vm.list[index].id ? Color.accentColor : Color.primary)
                                    
                                    Divider()
                                }
                            }
                        }
                        .refreshable {
                            Task {
                                await vm.fetchList(.refresh)
                            }
                        }
                        .onChange(of: appData.tappedTwice) { tapped in
                            if tapped == .leaderboard {
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
                .navigationTitle("Leaderboard")
                .navigationDestination(for: LeaderboardStack.self) { link in
                    switch link {
                    case .userProfile(let id):
                        UserProfileView(id: id)
                    case .userConnections(let userId, let initTab):
                        UserConnectionsView(userId: userId, activeTab: initTab)
                    }
                }
            }
        }
    }
}

#Preview {
    LeaderboardView()
}
