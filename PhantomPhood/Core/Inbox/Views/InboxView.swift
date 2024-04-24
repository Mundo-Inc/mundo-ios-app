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
                            vm.activeTab = .messages
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(InboxVM.Tab.messages.rawValue)
                                .font(.custom(style: .headline))
                                .fontWeight(.semibold)
                            
                            let unreadCount = conversationsManager.conversations.filter({ $0.unreadMessagesCount > 0 }).count
                            if unreadCount > 0 {
                                Text("\(unreadCount)")
                                    .font(.custom(style: .caption))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.black)
                                    .padding(.horizontal, 5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(height: 20)
                                            .frame(minWidth: 20)
                                            .shadow(color: Color.accentColor.opacity(0.3), radius: 3)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    .transition(AnyTransition.scale.animation(.bouncy))
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(vm.activeTab == .messages ? Color.accentColor : Color.secondary)
                    
                    Divider()
                        .frame(maxHeight: 20)
                    
                    Button {
                        withAnimation {
                            vm.activeTab = .notifications
                        }
                    } label: {
                        HStack {
                            Text(InboxVM.Tab.notifications.rawValue)
                                .font(.custom(style: .headline))
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
                                            .shadow(color: Color.accentColor.opacity(0.3), radius: 3)
                                            .foregroundStyle(Color.accentColor)
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(vm.activeTab == .notifications ? Color.accentColor : Color.secondary)
                }
                
                Divider()
            }
            .background(alignment: .bottomLeading) {
                Rectangle()
                    .frame(width: mainWindowSize.width / 2, height: 2)
                    .foregroundStyle(Color.accentColor)
                    .offset(x: vm.activeTab == .messages ? 0 : mainWindowSize.width / 2)
                    .animation(.bouncy, value: vm.activeTab)
            }
            
            TabView(selection: $vm.activeTab) {
                MessagesView()
                    .tag(InboxVM.Tab.messages)
                
                NotificationsView()
                    .tag(InboxVM.Tab.notifications)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .environmentObject(vm)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Inbox")
        .background(Color.themeBG.ignoresSafeArea())
        .task {
            await notificationsVM.getNotifications(.refresh)
        }
    }
}

#Preview {
    InboxView()
}
