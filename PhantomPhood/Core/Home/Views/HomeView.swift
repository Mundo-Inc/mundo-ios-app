//
//  HomeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var auth = Authentication.shared
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var notificationsVM = NotificationsVM.shared
    
    /// Used for pull to referesh - Percentage
    @State private var draggedAmount: Double = .zero
    private let dragAmountToRefresh: Double = 200.0
    
    // -
    @StateObject private var mediasViewModel = MediasVM()
    
    var body: some View {
        TabView(selection: $appData.homeActiveTab) {
            Group {
                if #available(iOS 17.0, *) {
                    ForYouView17()
                } else {
                    ForYouView(draggedAmount: $draggedAmount, dragAmountToRefresh: dragAmountToRefresh)
                }
            }
            .background(Color.themePrimary.ignoresSafeArea())
            .environment(\.colorScheme, .dark)
            .tag(HomeTab.forYou)
            
            FeedView(mediasViewModel: mediasViewModel)
                .tag(HomeTab.following)
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
                .foregroundStyle(.primary)
                .opacity(1.0 - min(draggedAmount * 2, 1))
                .offset(y: draggedAmount * 20)
                .background {
                    HStack {
                        Text("Drag down to referesh")
                        Image(systemName: "menubar.arrow.down.rectangle")
                    }
                    .font(.custom(style: .caption))
                    .opacity(draggedAmount <= 1/3 ? 0 : abs((draggedAmount - 1/3) * 3/2))
                }
                .offset(y: draggedAmount * 20)
            }
            
            HStack {
                Spacer()
                
                NavigationLink(value: AppRoute.inbox) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 20))
                        .frame(width: 40, height: 40)
                        .background(Circle().foregroundStyle(.black.opacity(0.5)))
                        .overlay(alignment: .topTrailing) {
                            if let unreadCount = notificationsVM.unreadCount, unreadCount > 0 {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(minWidth: 16)
                                    .frame(maxWidth: 26, maxHeight: 16)
                                    .overlay {
                                        Text(unreadCount > 99 ? "99+" : "\(unreadCount)")
                                            .font(.custom(style: .caption2))
                                            .foregroundStyle(Color.white)
                                    }
                            }
                        }
                }
                .foregroundStyle(.white)
                .onAppear {
                    Task {
                        await notificationsVM.updateUnreadNotificationsCount()
                    }
                }
                    
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HomeView()
}
