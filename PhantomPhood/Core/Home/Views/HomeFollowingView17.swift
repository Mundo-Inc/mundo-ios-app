//
//  HomeFollowingView17.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/9/24.
//

import SwiftUI

@available(iOS 17.0, *)
struct HomeFollowingView17: View {
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var appData = AppData.shared
    
    @ObservedObject private var vm: HomeVM
    
    init(vm: HomeVM) {
        self._vm = ObservedObject(wrappedValue: vm)
    }
    
    @State private var scrollPosition: String? = nil
    
    @Environment(\.mainWindowSafeAreaInsets) private var mainWindowSafeAreaInsets
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                if !vm.followingItems.isEmpty {
                    ForEach($vm.followingItems) { $item in
                        HomeActivityItem(item: $item, vm: vm, forTab: .following)
                            .containerRelativeFrame(.vertical)
                            .id($item.wrappedValue.id)
                    }
                } else if !vm.isFeedEmpty {
                    HomeActivityItemPlaceholder()
                        .containerRelativeFrame(.vertical)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.clear
                            .frame(height: mainWindowSafeAreaInsets.top + HomeView.headerHeight)
                        
                        if let currentUser = auth.currentUser {
                            HStack(spacing: 0) {
                                Image(.lookingGhost)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .rotationEffect(.degrees(90))
                                    .padding(.trailing, -10)
                                
                                VStack(alignment: .leading) {
                                    Text("Hi \(currentUser.name) 👋")
                                        .cfont(.title)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Welcome aboard!")
                                        .cfont(.headline)
                                        .fontWeight(.regular)
                                }
                            }
                            .padding(.top)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 0) {
                            if let leaderboard = vm.leaderboard {
                                ForEach(leaderboard.indices, id: \.self) { index in
                                    if index < 4 {
                                        let user = leaderboard[index]
                                        HStack {
                                            ProfileImage(user.profileImage, size: 40)
                                            
                                            VStack(alignment: .leading) {
                                                Text(user.name)
                                                    .cfont(.headline)
                                                    .fontWeight(.medium)
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)
                                                
                                                Text("@\(user.username)")
                                                    .cfont(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            if let connectionStatus = user.connectionStatus {
                                                switch connectionStatus.followingStatus {
                                                case .following:
                                                    Text("Following")
                                                        .cfont(.caption)
                                                        .foregroundStyle(.secondary)
                                                case .notFollowing:
                                                    HStack {
                                                        if vm.loadingSections.contains(.followRequest(user.id)) {
                                                            ProgressView()
                                                                .controlSize(.mini)
                                                        } else {
                                                            Text(connectionStatus.followedByStatus == .following ? "Follow Back" : "Follow")
                                                        }
                                                    }
                                                    .frame(height: 20)
                                                    .frame(minWidth: 60)
                                                    .cfont(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 1))
                                                    .onTapGesture {
                                                        Task {
                                                            await vm.followLeaderboardUser(userId: user.id)
                                                        }
                                                    }
                                                    .foregroundStyle(.primary)
                                                case .requested:
                                                    Text("Requested")
                                                        .cfont(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                                
                                            }
                                        }
                                        .padding()
                                        .onTapGesture {
                                            AppData.shared.goToUser(user.id)
                                        }
                                    }
                                    
                                    if index < 3 {
                                        Divider()
                                    }
                                }
                            } else {
                                ForEach(0..<4) { index in
                                    HStack {
                                        ProfileImage(nil, size: 40)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Name")
                                                .cfont(.headline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            
                                            Text("@username")
                                                .cfont(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack {
                                            Text("Follow")
                                        }
                                        .frame(height: 20)
                                        .frame(minWidth: 60)
                                        .cfont(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 1))
                                        .foregroundStyle(.primary)
                                    }
                                    .redacted(reason: .placeholder)
                                    .padding()
                                    
                                    if index < 3 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .background(Color.themePrimary, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        Text("Why not start by following our Top users?")
                            .shadow(radius: 3)
                            .foregroundStyle(.secondary)
                            .cfont(.subheadline)
                            .padding(.horizontal)
                            .padding(.top, 5)
                        
                        Spacer()
                    }
                    .containerRelativeFrame(.vertical)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hue: 284 / 360, saturation: 0.78, brightness: 0.51),
                                Color(hue: 232 / 360, saturation: 0.59, brightness: 0.43),
                                Color(hue: 284 / 360, saturation: 0.78, brightness: 0.51),
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .task {
                        await vm.getLeaderboardData()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .scrollTargetLayout()
        }
        .refreshable {
            Task {
                await vm.updateFollowingData(.refresh)
            }
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.never)
        .onChange(of: scrollPosition) { newValue in
            guard let scrollPosition,
                  let itemIndex = vm.followingItems.firstIndex(where: { $0.id == scrollPosition }) else { return }
            
            // Updateing `followingItemOnViewPort` on scroll
            vm.followingItemOnViewPort = vm.followingItems[itemIndex].id
            
            guard itemIndex >= vm.followingItems.count - 5 else { return }
            
            Task {
                await vm.updateFollowingData(.new)
            }
        }
        .onChange(of: appData.tappedTwice) { tapped in
            if tapped == .home && appData.homeActiveTab == .following {
                if let first = vm.followingItems.first {
                    withAnimation(.bouncy(duration: 1)) {
                        scrollPosition = first.id
                    }
                }
                appData.tappedTwice = nil
                Task {
                    if !vm.loadingSections.contains(.fetchingFollowingData) {
                        HapticManager.shared.impact(style: .light)
                        await vm.updateFollowingData(.refresh)
                        HapticManager.shared.notification(type: .success)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.themePrimary.ignoresSafeArea())
        .onAppear {
            if vm.scrollFollowingToItem == nil {
                vm.scrollFollowingToItem = { id in
                    withAnimation {
                        self.scrollPosition = id
                    }
                }
            }
        }
        .task {
            if vm.followingItems.isEmpty {
                await vm.updateFollowingData(.refresh)
            } else {
                await vm.updateFollowingIfNeeded()
            }
            
            if scrollPosition == nil {
                scrollPosition = vm.followingItems.first?.id
            }
            
            // Updateing `followingItemOnViewPort` on first data load
            if let scrollPosition, let itemIndex = vm.followingItems.firstIndex(where: { $0.id == scrollPosition }) {
                vm.followingItemOnViewPort = vm.followingItems[itemIndex].id
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    HomeFollowingView17(vm: HomeVM())
}
