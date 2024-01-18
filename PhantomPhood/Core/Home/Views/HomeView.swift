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
    
    @State private var reportId: String? = nil
    
    /// Used for pull to referesh - Percentage
    @State private var draggedAmount: Double = .zero
    private let dragAmountToRefresh: Double = 200.0
    
    // -
    @StateObject private var mediasViewModel = MediasViewModel()
    
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack(path: $appData.homeNavStack) {
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $appData.homeActiveTab) {
                    ForYouView(draggedAmount: $draggedAmount, dragAmountToRefresh: dragAmountToRefresh)
                        .tag(HomeTab.forYou)
                    
                    FeedView(mediasViewModel: mediasViewModel, reportId: $reportId)
                        .tag(HomeTab.followings)
                }
                .ignoresSafeArea()
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(Color.themeBG)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: AppRoute.notifications) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16))
                                .frame(width: 44, height: 44)
                                .background(Circle().foregroundStyle(.black))
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
                                            .onAppear {
                                                UNUserNotificationCenter.current().setBadgeCount(unreadCount)
                                            }
                                    } else {
                                        EmptyView()
                                            .onAppear {
                                                UNUserNotificationCenter.current().setBadgeCount(0)
                                            }
                                    }
                                }
                                .onAppear {
                                    Task {
                                        await notificationsVM.updateUnreadNotificationsCount()
                                    }
                                }
                        }
                        .foregroundStyle(.white)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 0) {
                            ZStack {
                                if appData.homeActiveTab == .forYou {
                                    Capsule()
                                        .matchedGeometryEffect(id: "selectedTab", in: namespace)
                                        .foregroundStyle(Color.accentColor)
                                }

                                Button {
                                    withAnimation {
                                        appData.homeActiveTab = .forYou
                                    }
                                } label: {
                                    Text(HomeTab.forYou.rawValue)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            ZStack {
                                if appData.homeActiveTab == .followings {
                                    Capsule()
                                        .matchedGeometryEffect(id: "selectedTab", in: namespace)
                                        .foregroundStyle(Color.accentColor)
                                }
                                
                                Button {
                                    withAnimation {
                                        appData.homeActiveTab = .followings
                                    }
                                } label: {
                                    Text(HomeTab.followings.rawValue)
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(width: 200, height: 32)
                        .background(Capsule().foregroundStyle(.black))
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
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .automatic)
                .navigationBarTitleDisplayMode(.inline)
                
                if reportId != nil {
                    ReportView(id: $reportId, type: .review)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: reportId)
                }
            }
            .handleNavigationDestination()
        }
    }
}

#Preview {
    HomeView()
}
