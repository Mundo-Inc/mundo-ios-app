//
//  NotificationsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI
import Kingfisher

struct NotificationsView: View {
    @StateObject private var vm = NotificationsViewModel()
    
    var body: some View {
        ZStack {
            Color.themeBG.ignoresSafeArea()
            
            List {
                ForEach(vm.notifications) { notification in
                    notificationItem(notification)
                        .onAppear {
                            if !vm.isLoading && !vm.notifications.isEmpty && vm.hasMore {
                                Task {
                                    await vm.loadMore(currentItem: notification)
                                }
                            }
                        }
                }
            }
            .refreshable {
                if !vm.isLoading {
                    await vm.getNotifications(.refresh)
                }
            }
            .listStyle(.inset)
            .navigationTitle("Notifications")
            .toolbar(content: {
                ToolbarItem {
                    if vm.isLoading {
                        ProgressView()
                            .transition(.opacity)
                    }
                }
            })
        }
    }
    
    func notificationItem(_ data: Notification) -> some View {
        HStack(alignment: .top) {
            ZStack {
                NavigationLink(value: HomeStack.userProfile(id: data.user.id)) {
                    EmptyView()
                }
                .buttonStyle(PlainButtonStyle())
                
                ProfileImage(data.user.profileImage, size: 44, cornerRadius: 10)
            }
            .frame(width: 44, height: 44)
            
            VStack {
                Group {
                    switch data.type {
                    case .reaction:
                        Text(data.user.name)
                            .bold()
                        Text(data.content)
                    case .comment:
                        Text(data.user.name)
                            .bold()
                        +
                        Text(" Commented on your activity.")
                        
                        Text(data.content)
                    case .follow:
                        Text(data.user.name)
                            .bold()
                        Text(data.content)
                    case .comment_mention:
                        Text(data.user.name)
                            .bold()
                        +
                        Text(" Mentioned you in a comment.")
                        
                        Text(data.content)
                    case .review_mention:
                        Text(data.user.name)
                            .bold()
                        +
                        Text(" Mentioned you in a review.")
                        
                        Text(data.content)
                    case .xp:
                        Text(data.user.name)
                            .bold()
                        Text("Got \(data.content) XP")
                    case .level_up:
                        Text(data.user.name)
                            .bold()
                        Text("Leveled Up")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.custom(style: .caption))
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(DateFormatter.getPassedTime(from: data.createdAt))
                .font(.custom(style: .caption))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
