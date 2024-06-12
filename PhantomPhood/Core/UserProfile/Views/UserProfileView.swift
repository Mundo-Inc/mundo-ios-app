//
//  UserProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/6/24.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var actionManager: ActionManager
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    @Environment(\.mainWindowSafeAreaInsets) private var mainWindowSafeAreaInsets
    
    @StateObject private var vm: UserProfileVM
    
    init(id: String) {
        self._vm = StateObject(wrappedValue: UserProfileVM(id: id))
    }
    
    init(username: String) {
        self._vm = StateObject(wrappedValue: UserProfileVM(username: username))
    }
    
    var body: some View {
        ScrollView {
            if let blockStatus = vm.blockStatus {
                BlockView(status: blockStatus)
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 15) {
                        HStack(spacing: 12) {
                            ProfileImage(vm.user?.profileImage, size: 80, cornerRadius: 15)
                            
                            VStack {
                                HStack {
                                    LevelView(level: vm.user?.progress.level ?? -1)
                                        .frame(height: 28)
                                    
                                    Text(vm.user?.name ?? "User Name")
                                        .font(.custom(style: .title2))
                                        .fontWeight(.bold)
                                    
                                    if let user = vm.user, user.verified {
                                        Image(systemName: "checkmark.seal")
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("@\(vm.user?.username ?? "Loading")")
                                    .font(.custom(style: .footnote))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .redacted(reason: vm.user == nil ? .placeholder : [])
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Group {
                                if let user = vm.user {
                                    Button {
                                        Task {
                                            switch user.connectionStatus.followingStatus {
                                            case .following:
                                                await vm.unfollow()
                                            case .notFollowing:
                                                await vm.follow()
                                            case .requested:
                                                await vm.unfollow()
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            if vm.loadingSections.contains(.followOperation) {
                                                ProgressView()
                                                    .controlSize(.mini)
                                            } else {
                                                switch user.connectionStatus.followingStatus {
                                                case .following:
                                                    Text("Unfollow")
                                                case .notFollowing:
                                                    Text(user.connectionStatus.followedByStatus == .following ? "Follow Back" : "Follow")
                                                case .requested:
                                                    Text("Requested")
                                                }
                                            }
                                        }
                                        .frame(height: 32)
                                        .frame(maxWidth: .infinity)
                                        .background(user.connectionStatus.followingStatus == .notFollowing ? Color.accentColor : Color.themeBorder)
                                        .clipShape(.rect(cornerRadius: 5))
                                        .foregroundStyle(user.connectionStatus.followingStatus == .notFollowing ? Color.black : Color.primary)
                                    }
                                    .task {
                                        await vm.getPosts(.refresh)
                                    }
                                } else {
                                    Button {} label: {
                                        Text("Loading")
                                            .frame(height: 32)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.themeBorder)
                                            .clipShape(.rect(cornerRadius: 5))
                                            .foregroundStyle(Color.primary)
                                    }
                                }
                            }
                            .disabled(vm.loadingSections.contains(.followOperation))
                            
                            Button {
                                Task {
                                    await vm.startConversation()
                                }
                            } label: {
                                HStack {
                                    if vm.loadingSections.contains(.startingConversation) {
                                        ProgressView()
                                            .controlSize(.mini)
                                    } else {
                                        Text("Message")
                                    }
                                }
                                .frame(height: 32)
                                .frame(maxWidth: .infinity)
                                .background(Color.themeBorder)
                                .clipShape(.rect(cornerRadius: 5))
                                .foregroundStyle(Color.primary)
                            }
                            .disabled(vm.loadingSections.contains(.startingConversation))
                            
                            Button {
                                ToastVM.shared.toast(.init(type: .info, title: "Coming Soon", message: "This feature is under development"))
//                                if let user = vm.user {
//                                    SheetsManager.shared.presenting = .gifting(.data(UserEssentials(userDetail: user)))
//                                }
                            } label: {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 18))
                                    .frame(height: 32)
                                    .frame(maxWidth: 70)
                                    .background(Color.yellow)
                                    .clipShape(.rect(cornerRadius: 5))
                                    .foregroundStyle(Color.black)
                            }
                            .disabled(vm.user == nil)
                        }
                        .padding(.horizontal)
                        .font(.custom(style: .footnote))
                        
                        
                        if let bio = vm.user?.bio {
                            Text(bio)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom(style: .footnote))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                                .foregroundStyle(.secondary)
                                .transition(AnyTransition.fade.animation(.easeIn))
                        }
                        
                        HStack(spacing: 0) {
                            Group {
                                VStack(spacing: 0) {
                                    Text((vm.user?.reviewsCount ?? 10).formattedWithSuffix())
                                        .font(.custom(style: .headline))
                                    
                                    Text("Reviews")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                                .onTapGesture {
                                    if let user = vm.user {
                                        AppData.shared.goTo(AppRoute.userActivities(userId: UserIdEnum.withId(user.id), activityType: .newReview))
                                    }
                                }
                                
                                VStack(spacing: 0) {
                                    Text((vm.user?.followersCount ?? 10).formattedWithSuffix())
                                        .font(.custom(style: .headline))
                                    
                                    Text("Followers")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                                .onTapGesture {
                                    if let user = vm.user {
                                        AppData.shared.goTo(AppRoute.userConnections(userId: user.id, initTab: .followers))
                                    }
                                }
                                
                                VStack(spacing: 0) {
                                    Text((vm.user?.followingCount ?? 10).formattedWithSuffix())
                                        .font(.custom(style: .headline))
                                    
                                    Text("Followings")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                                .onTapGesture {
                                    if let user = vm.user {
                                        AppData.shared.goTo(AppRoute.userConnections(userId: user.id, initTab: .followings))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 5)
                        .fontWeight(.semibold)
                        .redacted(reason: vm.user == nil ? .placeholder : [])
                    }
                    .padding(.top, 5)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity)
                    .background(Color.themePrimary)
                    
                    VStack(spacing: 0) {
                        if let user = vm.user {
                            if user.isPrivate && user.connectionStatus.followingStatus != .following {
                                VStack(spacing: 12) {
                                    Image(.profileLock)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 170)
                                        .padding(.bottom, 8)
                                    
                                    Text("Private Account")
                                        .font(.custom(style: .title3))
                                    
                                    Text("You need to follow \(user.name)\nto see their content")
                                        .font(.custom(style: .body))
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 50)
                            } else {
                                VStack(spacing: 0) {
                                    Divider()
                                    
                                    ScrollView(.horizontal) {
                                        HStack(spacing: 12) {
                                            ForEach(UserProfileVM.Tab.allCases, id: \.self) { tab in
                                                Button {
                                                    vm.activeTab = tab
                                                } label: {
                                                    Label {
                                                        Text(tab.title.uppercased())
                                                            .fontWeight(.semibold)
                                                    } icon: {
                                                        Image(systemName: tab.iconSystemName)
                                                    }
                                                    .frame(height: 32)
                                                    .padding(.horizontal)
                                                    .foregroundStyle(vm.activeTab == tab ? Color.accentColor : Color.secondary)
                                                    .opacity(tab.disabled ? 0.5 : 1)
                                                }
                                                .animation(.easeInOut(duration: 0), value: vm.activeTab)
                                                .disabled(tab.disabled)
                                                
                                                if tab != Array(UserProfileVM.Tab.allCases).last {
                                                    Divider()
                                                        .frame(maxHeight: 20)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.trailing)
                                    }
                                    .scrollIndicators(.never)
                                    
                                    Divider()
                                }
                                .background(Color.themePrimary)
                                .sticky(K.CoordinateSpace.userProfile)
                                
                                switch vm.activeTab {
                                case .posts:
                                    UserProfilePostsView(user: vm.user, activeTab: $vm.activeTab)
                                        .environmentObject(vm)
                                case .checkIns:
                                    UserProfileCheckInsView(.withId(user.id))
                                case .achievements:
                                    UserProfileAchievements(user: user)
                                case .lists:
                                    UserProfileListsView(user: user)
                                case .gifts:
                                    Text("Gifts")
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.themeBG)
                }
                .frame(minHeight: mainWindowSize.height, maxHeight: .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .coordinateSpace(name: K.CoordinateSpace.userProfile)
        .scrollIndicators(.hidden)
        .refreshable {
            if let userId = vm.user?.id {
                Task {
                    await vm.fetchUser(id: userId)
                }
                Task {
                    await vm.getPosts(.refresh)
                }
            }
        }
        .background(LinearGradient(stops: [.init(color: Color.themePrimary, location: 0.5), .init(color: Color.themeBG, location: 0.5)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.themePrimary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if vm.blockStatus != .hasBlocked {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        var actions: [ActionManager.Action] = []
                        if let blockStatus = vm.blockStatus, blockStatus == .isBlocked {
                            actions.append(.init(title: "Unblock User", alertMessage: "Are you sure you want unblock this user?", callback: {
                                Task {
                                    await vm.unblock()
                                }
                            }))
                        } else if vm.blockStatus == nil {
                            actions.append(.init(title: "Block User", alertMessage: "Are you sure you want to block this user?", callback: {
                                Task {
                                    await vm.block()
                                }
                            }))
                        }
                        if vm.user?.connectionStatus.followedByStatus == .following {
                            actions.append(.init(title: "Remove Follower", alertMessage: "Are you sure you want to remove this user from your followers?", callback: {
                                Task {
                                    await vm.removeFollower()
                                }
                            }))
                        }
                        actionManager.value = actions
                    } label: {
                        Label("Actions", systemImage: "ellipsis")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func BlockView(status: UserProfileVM.BlockStatus) -> some View {
        VStack {
            switch status {
            case .isBlocked:
                Text("You have blocked this user")
                    .font(.custom(style: .headline))
            case .hasBlocked:
                Text("This user has blocked you")
                    .font(.custom(style: .headline))
            }
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minHeight: mainWindowSize.height - mainWindowSafeAreaInsets.top - mainWindowSafeAreaInsets.bottom)
    }
}

#Preview {
    UserProfileView(id: "645c8b222134643c020860a5")
}
