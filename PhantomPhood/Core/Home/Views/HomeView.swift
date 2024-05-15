//
//  HomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

struct HomeView: View {
    static let headerHeight: CGFloat = 40
    @StateObject private var vm = HomeVM()
    
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var notificationsVM = NotificationsVM.shared
    @ObservedObject private var homeActivityInfoVM = HomeActivityInfoVM.shared
    @ObservedObject private var conversationsManager = ConversationsManager.shared
    
    var body: some View {
        TabView(selection: $appData.homeActiveTab) {
            if #available(iOS 17.0, *) {
                HomeFollowingView17(vm: vm)
                    .tag(HomeTab.following)
                
                HomeForYouView17(vm: vm)
                    .tag(HomeTab.forYou)
            } else {
                HomeFollowingView(vm: vm)
                    .tag(HomeTab.following)
                
                HomeForYouView(vm: vm)
                    .tag(HomeTab.forYou)
            }
        }
        .overlay(alignment: .top) {
            if #available(iOS 17.0, *) {
                HStack(spacing: 0) {
                    Button {
                        withAnimation {
                            appData.homeActiveTab = .following
                        }
                    } label: {
                        Text(HomeTab.following.rawValue)
                            .frame(height: 34)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button {
                        withAnimation {
                            appData.homeActiveTab = .forYou
                        }
                    } label: {
                        Text(HomeTab.forYou.rawValue)
                            .frame(height: 34)
                            .frame(maxWidth: .infinity)
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 200)
                .background(alignment: .leading) {
                    Capsule()
                        .frame(width: 96)
                        .foregroundStyle(Color.accentColor)
                        .padding(.all, 2)
                        .opacity(0.7)
                        .animation(.spring, value: appData.homeActiveTab)
                        .offset(x: appData.homeActiveTab == .following ? 0 : 100)
                }
                .background(Capsule().foregroundStyle(.black).opacity(0.3))
                .fontWeight(.semibold)
                .frame(maxHeight: Self.headerHeight)
            } else {
                HStack(spacing: 0) {
                    Button {
                        withAnimation {
                            appData.homeActiveTab = .following
                        }
                    } label: {
                        Text(HomeTab.following.rawValue)
                            .frame(height: 34)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button {
                        withAnimation {
                            appData.homeActiveTab = .forYou
                        }
                    } label: {
                        Text(HomeTab.forYou.rawValue)
                            .frame(height: 34)
                            .frame(maxWidth: .infinity)
                    }
                }
                .foregroundStyle(.white)
                .frame(width: 200)
                .background(alignment: .leading) {
                    Capsule()
                        .frame(width: 96)
                        .foregroundStyle(Color.accentColor)
                        .padding(.all, 2)
                        .opacity(0.7)
                        .animation(.spring, value: appData.homeActiveTab)
                        .offset(x: appData.homeActiveTab == .following ? 0 : 100)
                }
                .background(Capsule().foregroundStyle(.black).opacity(0.3))
                .font(.custom(style: .headline))
                .fontWeight(.semibold)
                .frame(maxHeight: Self.headerHeight)
                .foregroundStyle(.primary)
                .opacity(1.0 - min(vm.draggedAmount * 2, 1))
                .offset(y: vm.draggedAmount * 20)
                .background {
                    HStack {
                        Text("Drag down to referesh")
                        Image(systemName: "menubar.arrow.down.rectangle")
                    }
                    .font(.custom(style: .caption))
                    .opacity(vm.draggedAmount <= 1/3 ? 0 : abs((vm.draggedAmount - 1/3) * 3/2))
                }
                .offset(y: vm.draggedAmount * 20)
            }
            
            HStack {
                Spacer()
                
                NavigationLink(value: AppRoute.inbox) {
                    let unreadDms = conversationsManager.conversations.filter({ $0.unreadMessagesCount > 0 }).count
                    let unreadNotifications = notificationsVM.unreadCount ?? 0
                    Image(systemName: unreadDms > 0 ? "message.fill" : unreadNotifications > 0 ? "bell.fill" : "tray.fill")
                        .animation(.spring, value: unreadDms)
                        .font(.system(size: 20))
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(alignment: .topTrailing) {
                            if unreadDms > 0 {
                                Text(unreadDms > 99 ? "99+" : "\(unreadDms)")
                                    .font(.custom(style: .caption2))
                                    .foregroundStyle(Color.white)
                                    .frame(height: 16)
                                    .frame(minWidth: 12)
                                    .padding(.horizontal, 2)
                                    .background(Capsule().foregroundStyle(Color.accentColor))
                                    .transition(AnyTransition.scale.combined(with: .opacity).animation(.spring))
                            } else if unreadNotifications > 0 {
                                Text(unreadNotifications > 99 ? "99+" : "\(unreadNotifications)")
                                    .font(.custom(style: .caption2))
                                    .foregroundStyle(Color.black)
                                    .frame(height: 16)
                                    .frame(minWidth: 12)
                                    .padding(.horizontal, 2)
                                    .background(Capsule().foregroundStyle(Color.gray))
                                    .transition(AnyTransition.scale.combined(with: .opacity).animation(.spring))
                            }
                        }
                }
                .foregroundStyle(.white)
                .task {
                    await notificationsVM.updateUnreadNotificationsCount()
                }
                .task {
                    await notificationsVM.getFollowRequests(.refresh)
                }
            }
            .padding(.horizontal)
            .frame(maxHeight: Self.headerHeight)
        }
        .environment(\.colorScheme, .dark)
        .sheet(isPresented: Binding(optionalValue: $homeActivityInfoVM.data), onDismiss: {
            homeActivityInfoVM.reset()
        }) {
            if #available(iOS 16.4, *) {
                HomeActivityInfoView()
                    .presentationBackground(.thinMaterial)
            } else {
                HomeActivityInfoView()
            }
        }
    }
}

#Preview {
    HomeView()
}
