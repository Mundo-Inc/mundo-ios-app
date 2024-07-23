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
        NotificationsView()
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
            .navigationTitle("Notifications")
            .background(Color.themeBG.ignoresSafeArea())
            .task {
                await notificationsVM.getNotifications(.refresh)
            }
    }
}

#Preview {
    InboxView()
}
