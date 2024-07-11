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
        List {
            HStack {
                Circle()
                    .foregroundStyle(Color.themeBorder)
                    .frame(width: 46)
                    .overlay {
                        Image(systemName: "person.badge.clock")
                    }
                
                VStack(alignment: .leading) {
                    Text("Follow Requests")
                        .cfont(.headline)
                        .fontWeight(.bold)
                    
                    Group {
                        if let first = notificationsVM.followRequests.first, let followRequestsCount = notificationsVM.followRequestsCount {
                            if followRequestsCount > 1 {
                                Text("\(first.user.name), +\(followRequestsCount - 1) Others")
                            } else {
                                Text(first.user.name)
                            }
                        } else {
                            Text("No new request")
                        }
                    }
                    .cfont(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.forward")
            }
            .padding()
            .background(Color.themePrimary, in: RoundedRectangle(cornerRadius: 10))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden, edges: .top)
            .onTapGesture {
                AppData.shared.goTo(AppRoute.requests)
            }
            
            ForEach(notificationsVM.notificationsCluster.indices, id: \.self) { index in
                let cluster = notificationsVM.notificationsCluster[index]
                
                NotificationCluster(cluster)
                    .task {
                        await notificationsVM.loadMore(index: index)
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            if !notificationsVM.loadingSections.contains(.fetchingNotifications) {
                Task {
                    await notificationsVM.getNotifications(.refresh)
                }
            }
            if !notificationsVM.loadingSections.contains(.fetchingFollowRequests) {
                Task {
                    await notificationsVM.getFollowRequests(.refresh)
                }
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
                                    .cfont(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if let content = data.content {
                                Text(content)
                                    .cfont(.caption)
                                    .padding(.leading, data.title != nil ? 15 : 0)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text(data.createdAt.timeElapsed())
                            .cfont(.caption2)
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
                                .cfont(.caption)
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
