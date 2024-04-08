//
//  InboxView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/5/24.
//

import SwiftUI

struct InboxView: View {
    @StateObject private var vm = InboxVM()
    
    @ObservedObject private var notificationsVM = NotificationsVM.shared
    @ObservedObject private var conversationsManager = ConversationsManager.shared
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                HStack {
                    Button {
                        withAnimation {
                            notificationsVM.activeTab = .messages
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(NotificationsVM.Tab.messages.rawValue)
                                .font(.custom(style: .title3))
                                .fontWeight(.semibold)
                            
                            if conversationsManager.conversations.filter({ $0.unreadMessagesCount > 0 }).count > 0 {
                                Text("\(conversationsManager.conversations.filter({ $0.unreadMessagesCount > 0 }).count)")
                                    .font(.custom(style: .caption))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.black)
                                    .padding(.horizontal, 5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(height: 20)
                                            .frame(minWidth: 20)
                                            .shadow(color: Color.accentColor, radius: 2)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    .transition(AnyTransition.scale.animation(.bouncy))
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(notificationsVM.activeTab == .messages ? Color.accentColor : Color.secondary)
                    
                    Button {
                        withAnimation {
                            notificationsVM.activeTab = .notifications
                        }
                    } label: {
                        HStack {
                            Text(NotificationsVM.Tab.notifications.rawValue)
                                .font(.custom(style: .title3))
                                .fontWeight(.semibold)
                            
                            if let unreadCount = notificationsVM.unreadCount, unreadCount > 0 {
                                Text("\(unreadCount)")
                                    .font(.custom(style: .caption))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.black)
                                    .padding(.horizontal, 5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(height: 20)
                                            .frame(minWidth: 20)
                                            .shadow(color: Color.accentColor, radius: 2)
                                            .foregroundStyle(Color.accentColor)
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(notificationsVM.activeTab == .notifications ? Color.accentColor : Color.secondary)
                }
                
                Divider()
            }
            .background(alignment: .bottomLeading) {
                Rectangle()
                    .frame(width: mainWindowSize.width / 2, height: 2)
                    .foregroundStyle(Color.accentColor)
                    .offset(x: notificationsVM.activeTab == .messages ? 0 : mainWindowSize.width / 2)
                    .animation(.bouncy, value: notificationsVM.activeTab)
            }
            
            TabView(selection: $notificationsVM.activeTab) {
                MessagesView()
                    .tag(NotificationsVM.Tab.messages)
                
                NotificationsView()
                    .tag(NotificationsVM.Tab.notifications)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .environmentObject(vm)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.themeBG.ignoresSafeArea())
        .onAppear {
            Task {
                await notificationsVM.getNotifications(.refresh)
            }
        }
        .onChange(of: notificationsVM.notifications.isEmpty) { value in
            if !value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    Task {
                        await self.notificationsVM.seenNotifications()
                    }
                }
            }
        }
    }
}

#Preview {
    InboxView()
}
