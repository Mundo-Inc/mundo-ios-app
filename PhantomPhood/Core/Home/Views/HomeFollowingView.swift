//
//  HomeFollowingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI
import SwiftUIPager

struct HomeFollowingView: View {
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var appData = AppData.shared
    
    @ObservedObject private var vm: HomeVM
    
    init(vm: HomeVM) {
        self._vm = ObservedObject(wrappedValue: vm)
    }
    
    @StateObject private var page: Page = .first()
    
    @State private var readyToReferesh = true
    @State private var haptic = false
    
    @Environment(\.mainWindowSafeAreaInsets) private var mainWindowSafeAreaInsets
    
    var body: some View {
        ZStack {
            if !vm.followingItems.isEmpty {
                Pager(page: page, data: vm.followingItems.indices, id: \.self) { index in
                    HomeActivityItem(item: $vm.followingItems[index], vm: vm, forTab: .following)
                        .if(index == 0, transform: { view in
                            view
                                .gesture(
                                    DragGesture()
                                        .onChanged({ value in
                                            if page.index == 0 && value.location.y > value.startLocation.y {
                                                vm.draggedAmount = min(abs(value.translation.height) / HomeVM.dragAmountToRefresh, 1)
                                                
                                                if value.translation.height > HomeVM.dragAmountToRefresh {
                                                    if !self.haptic {
                                                        HapticManager.shared.impact(style: .heavy)
                                                        self.haptic = true
                                                    }
                                                } else {
                                                    self.haptic = false
                                                }
                                            }
                                        })
                                        .onEnded({ value in
                                            if value.translation.height > HomeVM.dragAmountToRefresh {
                                                if !vm.loadingSections.contains(.fetchingFollowingData) && readyToReferesh {
                                                    Task {
                                                        HapticManager.shared.impact(style: .light)
                                                        await vm.updateFollowingData(.refresh)
                                                        HapticManager.shared.notification(type: .success)
                                                    }
                                                }
                                            }
                                            
                                            if vm.draggedAmount != .zero {
                                                withAnimation {
                                                    vm.draggedAmount = .zero
                                                }
                                            }
                                            readyToReferesh = true
                                        })
                                )
                                .blur(radius: vm.draggedAmount < 0.1 ? 0 : vm.draggedAmount * 8)
                        })
                }
                .singlePagination()
                .pagingPriority(.simultaneous)
                .bounces(false)
                .vertical()
                .onPageChanged({ pageIndex in
                    if !vm.followingItems.isEmpty && pageIndex >= 0 {
                        vm.followingItemOnViewPort = vm.followingItems[pageIndex].id
                    }
                    
                    guard pageIndex >= vm.followingItems.count - 5 else { return }
                    
                    Task {
                        await vm.updateFollowingData(.new)
                    }
                })
                .overlay(alignment: .top) {
                    ProgressView(value: vm.draggedAmount)
                        .opacity(vm.draggedAmount < 0.1 ? 0 : vm.draggedAmount * 0.5 + 0.5)
                }
                .ignoresSafeArea(edges: .top)
                .onChange(of: appData.tappedTwice) { tapped in
                    if tapped == .home && appData.homeActiveTab == .following {
                        withAnimation {
                            page.update(.moveToFirst)
                        }
                        appData.tappedTwice = nil
                        if !vm.loadingSections.contains(.fetchingFollowingData) {
                            Task {
                                HapticManager.shared.impact(style: .light)
                                await vm.updateFollowingData(.refresh)
                                HapticManager.shared.notification(type: .success)
                            }
                        }
                    }
                }
            } else if !vm.isFeedEmpty {
                HomeActivityItemPlaceholder()
                    .ignoresSafeArea(edges: .top)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(height: mainWindowSafeAreaInsets.top + HomeView.headerHeight)
                    
                    if let currentUser = auth.currentUser {
                        VStack(alignment: .leading) {
                            HStack(spacing: 0) {
                                Image(.lookingGhost)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .rotationEffect(.degrees(90))
                                    .padding(.trailing, -10)
                                
                                Text("Hi \(currentUser.name) 👋")
                                    .font(.custom(style: .title))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Text("Welcome aboard!")
                                .font(.custom(style: .title3))
                                .fontWeight(.medium)
                                .padding(.bottom)
                                .padding(.horizontal)
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
                                                .font(.custom(style: .headline))
                                                .fontWeight(.medium)
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            
                                            Text("@\(user.username)")
                                                .font(.custom(style: .caption))
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if let connectionStatus = user.connectionStatus {
                                            switch connectionStatus.followingStatus {
                                            case .following:
                                                Text("Following")
                                                    .font(.custom(style: .caption))
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
                                                .font(.custom(style: .caption))
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
                                                    .font(.custom(style: .caption))
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
                                            .font(.custom(style: .headline))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        
                                        Text("@username")
                                            .font(.custom(style: .caption))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        Text("Follow")
                                    }
                                    .frame(height: 20)
                                    .frame(minWidth: 60)
                                    .font(.custom(style: .caption))
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
                        .font(.custom(style: .subheadline))
                        .padding(.horizontal)
                        .padding(.top, 5)
                    
                    Spacer()
                    
                    Text("")
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color(hue: 202 / 360, saturation: 0.79, brightness: 0.5),
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
        .onAppear {
            if vm.scrollFollowingToItem == nil {
                vm.scrollFollowingToItem = { id in
                    if let index = vm.followingItems.firstIndex(where: { $0.id == id }) {
                        withAnimation {
                            self.page.index = index
                        }
                    }
                }
            }
        }
        .task {
            if vm.followingItems.isEmpty {
                await vm.updateFollowingData(.refresh)
            } else {
                await vm.updateForYouIfNeeded()
            }
            
            // Updateing `followingItemOnViewPort` on first data load
            if !vm.followingItems.isEmpty, vm.followingItems.count >= page.index + 1 {
                vm.followingItemOnViewPort = vm.followingItems[page.index].id
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeFollowingView(vm: HomeVM())
    }
}
