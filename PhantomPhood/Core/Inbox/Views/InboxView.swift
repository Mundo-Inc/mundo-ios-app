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
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            TabView(selection: $vm.activeTab) {
                ConversationsView()
                    .tag(InboxVM.Tab.messages)
                
                NotificationsView()
                    .tag(InboxVM.Tab.notifications)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let unreadCount = notificationsVM.unreadCount, unreadCount > 0 {
                    Text("\(unreadCount)")
                        .cfont(.caption)
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
        }
        .environmentObject(vm)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Inbox")
        .background(Color.themeBG.ignoresSafeArea())
        .task {
            await notificationsVM.getNotifications(.refresh)
        }
    }
    
    private var header: some View {
        HStack {
            Button {
                vm.activeTab = .messages
            } label: {
                Text(InboxVM.Tab.messages.title)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(vm.activeTab == .messages ? Color.accentColor : Color.secondary)
            
            Button {
                vm.activeTab = .notifications
            } label: {
                Text(InboxVM.Tab.notifications.title)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(vm.activeTab == .notifications ? Color.accentColor : Color.secondary)
        }
        .cfont(.headline)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity)
        .background(alignment: .bottomLeading) {
            UnevenRoundedRectangle(topLeadingRadius: 2, topTrailingRadius: 2)
                .frame(height: 4)
                .frame(width: mainWindowSize.width / 2)
                .foregroundStyle(Color.accentColor)
                .offset(x: vm.activeTab == .messages ? 0 : mainWindowSize.width / 2)
                .animation(.spring, value: vm.activeTab)
        }
        .background(alignment: .bottomLeading) {
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    NavigationStack {
        InboxView()
    }
}
