//
//  UserProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/6/24.
//

import SwiftUI

struct UserProfileView: View {
    enum UserProfileTab: Hashable, CaseIterable {
        case posts
        case achievements
        case lists
        case gifts
        
        var title: String {
            switch self {
            case .posts:
                return "Posts"
            case .achievements:
                return "Achievements"
            case .lists:
                return "Lists"
            case .gifts:
                return "Gifts"
            }
        }
    }
    
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
    
    @State private var activeTab: UserProfileTab = .posts
    
    var body: some View {
        ScrollView {
            if let blockStatus = vm.blockStatus {
                VStack {
                    switch blockStatus {
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
                                if let user = vm.user {
                                    SheetsManager.shared.presenting = .gifting(.data(UserEssentials(userDetail: user)))
                                }
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
                                ScrollView(.horizontal) {
                                    HStack(spacing: 12) {
                                        ForEach(UserProfileTab.allCases, id: \.self) { tab in
                                            Button {
                                                activeTab = tab
                                            } label: {
                                                Text(tab.title.uppercased())
                                                    .frame(height: 32)
                                                    .padding(.horizontal)
                                                    .background(activeTab == tab ? Color.accentColor : Color.clear, in: RoundedRectangle(cornerRadius: 5))
                                                    .background {
                                                        if activeTab != tab {
                                                            RoundedRectangle(cornerRadius: 5)
                                                                .stroke(Color.accentColor, lineWidth: 2)
                                                        }
                                                    }
                                                    .opacity(activeTab == tab ? 1 : 0.6)
                                            }
                                            .foregroundStyle(activeTab == tab ? Color.black : Color.accentColor)
                                            .animation(.easeInOut(duration: 0), value: activeTab)
                                            .disabled(tab == .gifts)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                }
                                .scrollIndicators(.never)
                                
                                Group {
                                    switch activeTab {
                                    case .posts:
                                        UserProfilePostsView(user: vm.user, activeTab: $activeTab)
                                    case .achievements:
                                        UserProfileAchievements(user: user)
                                    case .lists:
                                        UserProfileListsView(user: user)
                                    case .gifts:
                                        Text("Gifts")
                                    }
                                }
                                .environmentObject(vm)
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
}

#Preview {
    UserProfileView(id: "645c8b222134643c020860a5")
}
