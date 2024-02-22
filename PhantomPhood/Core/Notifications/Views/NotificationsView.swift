//
//  NotificationsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject private var vm = NotificationsVM.shared
    @ObservedObject private var appData = AppData.shared
    
    var body: some View {
        ZStack {
            Color.themeBG
                .ignoresSafeArea()
                .onAppear {
                    Task {
                        await vm.getNotifications(.refresh)
                    }
                }
            
            if !vm.notifications.isEmpty {
                Color.clear
                    .frame(width: 0, height: 0)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                            Task {
                                await self.vm.seenNotifications()
                            }
                        }
                    }
            }
            
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
        }
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
    
    func notificationItem(_ data: Notification) -> some View {
        HStack(alignment: .top) {
            if let user = data.user {
                ProfileImage(user.profileImage, size: 44, cornerRadius: 10)
                    .frame(width: 44, height: 44)
                    .onTapGesture {
                        appData.homeNavStack.append(AppRoute.userProfile(userId: user.id))
                    }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Color.themePrimary)
            }
            
            Button {
                if let activity = data.activity {
                    appData.homeNavStack.append(AppRoute.userActivity(id: activity))
                }
            } label: {
                HStack(alignment: .top) {
                    VStack(spacing: 5) {
                        Group {
                            switch data.type {
                            case NotificationType.comment.rawValue:
                                if let user = data.user {
                                    Group {
                                        Text(user.name)
                                            .bold()
                                        +
                                        Text(" Commented on your activity.")
                                    }
                                    .frame(minHeight: 20)
                                }
                                
                                Text(data.content)
                                    .frame(minHeight: 18)
                            case NotificationType.comment_mention.rawValue:
                                if let user = data.user {
                                    Group {
                                        Text(user.name)
                                            .bold()
                                        +
                                        Text(" Mentioned you in a comment.")
                                    }
                                    .frame(minHeight: 20)
                                }
                                
                                Text(data.content)
                                    .frame(minHeight: 18)
                            case NotificationType.review_mention.rawValue:
                                if let user = data.user {
                                    Group {
                                        Text(user.name)
                                            .bold()
                                        +
                                        Text(" Mentioned you in a review.")
                                    }
                                    .frame(minHeight: 20)
                                }
                                
                                Text(data.content)
                                    .frame(minHeight: 18)
                            case NotificationType.xp.rawValue:
                                if let user = data.user {
                                    Text(user.name)
                                        .bold()
                                        .frame(minHeight: 20)
                                }
                                
                                Text("Got \(data.content) XP")
                                    .frame(minHeight: 18)
                            case NotificationType.level_up.rawValue:
                                if let user = data.user {
                                    Text(user.name)
                                        .bold()
                                        .frame(minHeight: 20)
                                }
                                
                                Text("Leveled Up")
                                    .frame(minHeight: 18)
                            default:
                                if !data.content.isEmpty {
                                    if let user = data.user {
                                        Text(user.name)
                                            .bold()
                                            .frame(minHeight: 20)
                                    }
                                    
                                    Text(data.content)
                                        .frame(minHeight: 18)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .font(.custom(style: .caption))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        if data.readAt == nil {
                            Circle()
                                .frame(width: 6, height: 6)
                                .shadow(color: Color.accentColor, radius: 2)
                                .foregroundStyle(Color.accentColor)
                                .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.2)))
                        }
                        
                        Text(data.createdAt.timeElapsed())
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
