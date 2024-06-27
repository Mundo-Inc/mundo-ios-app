//
//  MyProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 16.09.2023.
//

import SwiftUI

struct MyProfileView: View {
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    @Environment(\.mainWindowSafeAreaInsets) private var mainWindowSafeAreaInsets
    
    @StateObject private var vm = MyProfileVM()
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 15) {
                        HStack(spacing: 12) {
                            ProfileImage(auth.currentUser?.profileImage, size: 80, cornerRadius: 15)
                            
                            VStack {
                                HStack {
                                    LevelView(level: auth.currentUser?.progress.level ?? -1)
                                        .frame(height: 28)
                                    
                                    Text(auth.currentUser?.name ?? "User Name")
                                        .font(.custom(style: .title2))
                                        .fontWeight(.bold)
                                    
                                    if let user = auth.currentUser, user.verified {
                                        Image(systemName: "checkmark.seal")
                                            .foregroundStyle(.blue)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("@\(auth.currentUser?.username ?? "Loading")")
                                    .font(.custom(style: .footnote))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Button {
                                vm.presentedSheet = .editProfile
                            } label: {
                                Text("Edit profile")
                                    .frame(height: 32)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.themeBorder)
                                    .clipShape(.rect(cornerRadius: 5))
                                    .foregroundStyle(Color.primary)
                            }
                            
                            if let currentUser = auth.currentUser, let url = URL(string: "\(K.ENV.WebsiteURL)/user/@\(currentUser.username)") {
                                ShareLink(item: url, message: Text("Join \(currentUser.name) on a journey of taste")) {
                                    Text("Share profile")
                                        .frame(height: 32)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.themeBorder)
                                        .clipShape(.rect(cornerRadius: 5))
                                        .foregroundStyle(Color.primary)
                                }
                            } else {
                                Button {} label: {
                                    Text("Share profile")
                                        .frame(height: 32)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.themeBorder)
                                        .clipShape(.rect(cornerRadius: 5))
                                        .foregroundStyle(Color.primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .font(.custom(style: .footnote))
                        
                        
                        if let bio = auth.currentUser?.bio {
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
                                    Text((auth.currentUser?.reviewsCount ?? 10).formattedWithSuffix())
                                        .font(.custom(style: .headline))
                                    
                                    Text("Reviews")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                                .onTapGesture {
                                    vm.activityType = .reviews
                                    AppData.shared.goTo(AppRoute.myActivities(vm: vm, selected: nil))
                                }
                                
                                VStack(spacing: 0) {
                                    Text((auth.currentUser?.followersCount ?? 10).formattedWithSuffix())
                                        .font(.custom(style: .headline))
                                    
                                    Text("Followers")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                                .onTapGesture {
                                    if let user = auth.currentUser {
                                        AppData.shared.goTo(AppRoute.userConnections(userId: user.id, initTab: .followers))
                                    }
                                }
                                
                                VStack(spacing: 0) {
                                    Text((auth.currentUser?.followingCount ?? 10).formattedWithSuffix())
                                        .font(.custom(style: .headline))
                                    
                                    Text("Followings")
                                        .font(.custom(style: .caption))
                                        .foregroundStyle(.secondary)
                                }
                                .onTapGesture {
                                    if let user = auth.currentUser {
                                        AppData.shared.goTo(AppRoute.userConnections(userId: user.id, initTab: .followings))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 5)
                        .fontWeight(.semibold)
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color.themePrimary)
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Divider()
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ForEach(MyProfileVM.Tab.allCases, id: \.self) { tab in
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
                                        .disabled(tab.disabled)
                                        .animation(.easeInOut(duration: 0), value: vm.activeTab)
                                        
                                        if tab != Array(MyProfileVM.Tab.allCases).last {
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
                        .sticky(K.CoordinateSpace.myProfile)
                        
                        switch vm.activeTab {
                        case .posts:
                            MyProfilePostsView(activeTab: $vm.activeTab)
                                .environmentObject(vm)
                        case .checkIns:
                            UserProfileCheckInsView(.currentUser)
                        case .achievements:
                            ProfileAchievements()
                        case .lists:
                            MyProfileListsView()
                        case .gifts:
                            MyProfileGiftsView()
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.themeBG)
                }
                .frame(minHeight: mainWindowSize.height, maxHeight: .infinity)
                .frame(maxWidth: .infinity)
            }
            .coordinateSpace(name: K.CoordinateSpace.myProfile)
            .scrollIndicators(.hidden)
            .refreshable {
                Task {
                    await auth.updateUserInfo()
                }
                Task {
                    await vm.getPosts(.refresh)
                }
            }
            .background(LinearGradient(stops: [.init(color: Color.themePrimary, location: 0.5), .init(color: Color.themeBG, location: 0.5)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
            .task {
                await vm.getPosts(.refresh)
            }
            .fullScreenCover(item: $vm.presentedSheet) { sheet in
                switch sheet {
                case .editProfile:
                    EditProfileView()
                }
            }
            .onChange(of: appData.tappedTwice) { tapped in
                if tapped == .myProfile {
                    withAnimation {
                        proxy.scrollTo(1)
                    }
                    appData.tappedTwice = nil
                }
            }
        }
    }
}

#Preview {
    MyProfileView()
}
