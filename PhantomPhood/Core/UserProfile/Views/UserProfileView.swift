//
//  UserProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

enum UserProfileTab: String, Hashable, CaseIterable {
    case stats = "Stats"
    case achievements = "Acheivements"
    case lists = "Lists"
}


struct UserProfileView: View {
    let id: String
    
    @StateObject private var vm: UserProfileViewModel
    @State private var activeTab: UserProfileTab = .stats
    
    init(id: String) {
        self.id = id
        self._vm = StateObject(wrappedValue: UserProfileViewModel(id: id))
    }
    
    var body: some View {
        ScrollView {
            if let blockStatus = vm.blockStatus {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 200)
                    .ignoresSafeArea()
                    .overlay {
                        switch blockStatus {
                        case .isBlocked:
                            Text("You have blocked this user")
                                .font(.custom(style: .headline))
                        case .hasBlocked:
                            Text("This user has blocked you")
                                .font(.custom(style: .headline))
                        }
                    }
            } else {
                VStack {
                    HStack(spacing: 12) {
                        ProfileImage(vm.user?.profileImage, size: 82, cornerRadius: 15)
                        
                        VStack {
                            if (vm.user != nil && vm.user!.verified) {
                                HStack {
                                    Text(vm.user?.name ?? "User Name")
                                        .font(.custom(style: .title2))
                                        .bold()
                                    Image(systemName: "checkmark.seal")
                                        .foregroundStyle(.blue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            } else {
                                Text(vm.user?.name ?? "User Name")
                                    .font(.custom(style: .title2))
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Text("@\(vm.user?.username ?? "Loading")")
                                .font(.custom(style: .footnote))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Group {
                                if let isFollowing = vm.isFollowing {
                                    if isFollowing {
                                        Button {
                                            Task {
                                                await vm.unfollow()
                                            }
                                        } label: {
                                            Text("Unfollow")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(BorderedButtonStyle())
                                    } else {
                                        Button {
                                            Task {
                                                await vm.follow()
                                            }
                                        } label: {
                                            Text("Follow")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(BorderedProminentButtonStyle())
                                    }
                                } else {
                                    Button {} label: {
                                        Text("Loading")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(BorderedButtonStyle())
                                }
                            }
                            .font(.custom(style: .footnote))
                            .controlSize(.small)
                            
                        }
                        .redacted(reason: vm.user == nil ? .placeholder : [])
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    
                    if let bio = vm.user?.bio, !bio.isEmpty {
                        Text(bio)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .footnote))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    
                    
                    HStack {
                        Divider()
                            .opacity(0)
                        
                        Button {
                            withAnimation {
                                activeTab = .stats
                            }
                        } label: {
                            Text(UserProfileTab.stats.rawValue)
                                .padding(.vertical)
                                .padding(.leading)
                        }
                        .foregroundStyle(
                            activeTab == UserProfileTab.stats ? Color.accentColor : Color.secondary
                        )
                        
                        Spacer()
                        Divider()
                            .frame(maxHeight: 20)
                        
                        Button {
                            withAnimation {
                                activeTab = .achievements
                            }
                        } label: {
                            Text(UserProfileTab.achievements.rawValue)
                                .padding()
                        }
                        .foregroundStyle(
                            activeTab == UserProfileTab.achievements ? Color.accentColor : Color.secondary
                        )
                        
                        Divider()
                            .frame(maxHeight: 20)
                        Spacer()
                        
                        Button {
                            withAnimation {
                                activeTab = .lists
                            }
                        } label: {
                            Text(UserProfileTab.lists.rawValue)
                                .padding(.vertical)
                                .padding(.trailing)
                        }
                        .foregroundStyle(
                            activeTab == UserProfileTab.lists ? Color.accentColor : Color.secondary
                        )
                        
                        Divider()
                            .opacity(0)
                    }
                    .font(.custom(style: .footnote))
                    .bold()
                    .textCase(.uppercase)
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .background {
                    Color.themePrimary
                        .clipShape(
                            .rect(
                                bottomLeadingRadius: 20,
                                bottomTrailingRadius: 20
                            )
                        )
                }
                
                VStack {
                    Group {
                        switch activeTab {
                        case .stats:
                            UserProfileStats(user: vm.user, activeTab: $activeTab)
                        case .achievements:
                            UserProfileAchievements(user: vm.user)
                        case .lists:
                            if let user = vm.user {
                                UserProfileListsView(user: user)
                            } else {
                                VStack {
                                    Text("Loading")
                                }
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .frame(minHeight: UIScreen.main.bounds.height / 1.5)
                .background(
                    Color.themeBG
                        .offset(y: -30)
                )
                .zIndex(-1)
            }
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await vm.fetchUser()
        }
        .frame(maxHeight: .infinity)
        .background {
            if let _ = vm.blockStatus {
                Color.themePrimary.ignoresSafeArea()
                    .frame(maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    Color.themePrimary.ignoresSafeArea()
                    Color.themeBG.ignoresSafeArea()
                }
                .frame(maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Actions", isPresented: $vm.showActions, actions: {
            if let blockStatus = vm.blockStatus, blockStatus == .isBlocked {
                Button("Unblock User", role: .destructive) {
                    Task {
                        await vm.unblock()
                    }
                }
            } else if vm.blockStatus == nil {
                Button("Block User", role: .destructive) {
                    Task {
                        await vm.block()
                    }
                }
            }
        })
        .toolbar {
            if vm.blockStatus != .hasBlocked {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showActions = true
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        }
        
        if let blockStatus = vm.blockStatus, blockStatus == .isBlocked {
            Button {
                Task {
                    await vm.unblock()
                }
            } label: {
                Text("Unblock")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.themePrimary)
                    .padding(.bottom)
                    .font(.custom(style: .body))
            }
            .disabled(vm.isLoading)
        }
    }
}

#Preview {
    UserProfileView(id: "645c8b222134643c020860a5")
}
