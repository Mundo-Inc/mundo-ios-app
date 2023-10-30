//
//  LeaderboardView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var auth: Authentication
    
    @StateObject private var vm = LeaderboardViewModel()
    
    var body: some View {
        NavigationStack(path: $appData.leaderboardNavStack) {
            ZStack {
                Color.themeBG.ignoresSafeArea()
                
                VStack {
                    HStack(spacing: 10) {
                        if let user = auth.user, let profileImage = URL(string: user.profileImage) {
                            CacheAsyncImage(url: profileImage) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .foregroundStyle(.tertiary)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                default:
                                    Rectangle()
                                        .overlay {
                                            Image(systemName: "exclamationmark.icloud")
                                                .foregroundStyle(.red)
                                        }
                                }
                            }
                            .frame(width: 64, height: 64)
                            .contentShape(RoundedRectangle(cornerRadius: 15))
                            .clipShape(.rect(cornerRadius: 15))
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 64, height: 64)
                                .foregroundStyle(Color.themePrimary)
                                .overlay {
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 36))
                                        .foregroundStyle(Color.accentColor)
                                }
                        }
                        
                        VStack {
                            Text(auth.user?.name ?? "User Name")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ProgressView(value: auth.user == nil ? 0 : Double(auth.user!.progress.xp) / Double(auth.user!.progress.xp + auth.user!.remainingXp))
                                .foregroundStyle(.secondary)
                                .progressViewStyle(.linear)
                            
                            HStack {
                                Text("\(auth.user?.progress.xp ?? 100) XP")
                                    .font(.custom(style: .body))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("#\(auth.user?.rank ?? 10) Global")
                                    .font(.custom(style: .body))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .redacted(reason: auth.user == nil ? .placeholder : [])
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LevelView(level: auth.user != nil ? auth.user!.progress.level : -1)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 46, height: 54)
                        
                    }
                    .padding()
                    
                    Divider()
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(vm.list.indices, id: \.self) { index in
                                NavigationLink(value: LeaderboardStack.userProfile(id: vm.list[index].id)) {
                                    HStack {
                                        Text("#\(index + 1)")
                                            .font(.custom(style: .headline))
                                            .foregroundStyle(.secondary)
                                            .frame(minWidth: 40)
                                        
                                        if !vm.list[index].profileImage.isEmpty, let profileImageURL = URL(string: vm.list[index].profileImage) {
                                            CacheAsyncImage(url: profileImageURL) { phase in
                                                switch phase {
                                                case .empty:
                                                    Circle()
                                                        .foregroundStyle(Color.themePrimary)
                                                        .overlay {
                                                            ProgressView()
                                                        }
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                default:
                                                    Circle()
                                                        .foregroundStyle(Color.themePrimary)
                                                        .overlay {
                                                            Image(systemName: "exclamationmark.icloud")
                                                                .foregroundStyle(.red)
                                                        }
                                                }
                                            }
                                            .frame(width: 36, height: 36)
                                            .contentShape(Circle())
                                            .clipShape(Circle())
                                        } else {
                                            Circle()
                                                .foregroundStyle(Color.themePrimary)
                                                .frame(width: 36, height: 36)
                                                .overlay {
                                                    Image(systemName: "person.crop.circle")
                                                        .foregroundStyle(.secondary)
                                                }
                                        }
                                        
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
                                .foregroundStyle(auth.user?.id == vm.list[index].id ? Color.accentColor : Color.primary)
                                
                                Divider()
                            }
                        }
                    }
                    .refreshable {
                        Task {
                            await vm.fetchList(.refresh)
                        }
                    }
                }
                .navigationTitle("Leaderboard")
                .navigationDestination(for: LeaderboardStack.self) { link in
                    switch link {
                    case .userProfile(let id):
                        UserProfileView(id: id)
                    }
                }
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
            .environmentObject(AppData())
            .environmentObject(Authentication())
    }
}
