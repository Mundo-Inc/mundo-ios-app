//
//  NotificationsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 15.09.2023.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject private var notificationsVM = NotificationsVM.shared
    
    var body: some View {
        List(notificationsVM.notificationsCluster.indices, id: \.self) { index in
            let cluster = notificationsVM.notificationsCluster[index]
            
            NotificationCluster(cluster)
                .onAppear {
                    if !notificationsVM.isLoading && notificationsVM.hasMore {
                        Task {
                            await notificationsVM.loadMore(index: index)
                        }
                    }
                }
        }
        .listStyle(.grouped)
        .refreshable {
            if !notificationsVM.isLoading {
                await notificationsVM.getNotifications(.refresh)
            }
        }
        .scrollIndicators(.hidden)
        .task {
            await self.notificationsVM.seenNotifications()
        }
    }
        
    @ViewBuilder
    private func NotificationCluster(_ cluster: NotificationsVM.NotificationsUserCluster) -> some View {
        Section {
            ForEach(cluster.items) { data in
                Button {
                    if let activity = data.activity {
                        AppData.shared.goTo(AppRoute.userActivity(id: activity))
                    }
                } label: {
                    HStack(alignment: .top) {
                        VStack(spacing: 8) {
                            if let title = data.title {
                                Text(title)
                                    .font(.custom(style: .caption))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if let content = data.content {
                                Text(content)
                                    .font(.custom(style: .caption))
                                    .padding(.leading, data.title != nil ? 15 : 0)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text(data.createdAt.timeElapsed())
                            .font(.custom(style: .caption2))
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.primary)
                .listRowBackground(data.readAt == nil ? Color.accentColor.opacity(0.15) : Color.themePrimary)
            }
        } header: {
            Group {
                if let user = cluster.user {
                    HStack {
                        ProfileImage(user.profileImage, size: 44, cornerRadius: 10)
                            .frame(width: 44, height: 44)
                            .onTapGesture {
                                AppData.shared.goToUser(user.id)
                            }
                        
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Text("@\(user.username)")
                                .font(.custom(style: .caption))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .onTapGesture {
                        AppData.shared.goToUser(user.id)
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 44, height: 44)
                        .foregroundStyle(Color.themePrimary)
                }
            }
            .padding(.bottom, 5)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}
