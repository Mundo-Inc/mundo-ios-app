//
//  MyConnections.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/31/23.
//

import SwiftUI

struct MyConnections: View {
    @State private var activeTab: UserConnectionsTab
    
    @StateObject private var vm = MyConnectionsVM()
    
    init(activeTab: UserConnectionsTab = .followers) {
        self._activeTab = State(wrappedValue: activeTab)
    }
    
    @Environment(\.mainWindowSize) private var mainWindowSize
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button {
                        withAnimation {
                            activeTab = .followers
                        }
                    } label: {
                        Text("Followers".uppercased())
                            .cfont(.footnote)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical)
                    }
                    .foregroundStyle(activeTab == .followers ? Color.accentColor : Color.secondary)
                    
                    Divider()
                        .frame(maxHeight: 20)
                    
                    Button {
                        withAnimation {
                            activeTab = .followings
                        }
                    } label: {
                        Text("Followings".uppercased())
                            .cfont(.footnote)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical)
                    }
                    .foregroundStyle(activeTab == .followings ? Color.accentColor : Color.secondary)
                }
                
                Divider()
            }
            .background(alignment: .bottomLeading) {
                Rectangle()
                    .frame(width: mainWindowSize.width / 2, height: 2)
                    .foregroundStyle(Color.accentColor)
                    .offset(x: activeTab == .followers ? 0 : mainWindowSize.width / 2)
                    .animation(.bouncy, value: activeTab)
            }
            
            List {
                switch activeTab {
                case .followers:
                    if let connections = vm.followers {
                        ForEach(connections) { connection in
                            UserCard(connection: connection)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await vm.removeFollower(userId: connection.user.id)
                                        }
                                    } label: {
                                        Label("Remove", systemImage: "person.crop.circle.fill.badge.xmark")
                                    }
                                }
                                .disabled(vm.loadingSections.contains(.removingFollower(connection.user.id)))
                                .onAppear {
                                    Task {
                                        await vm.loadMore(type: .followers, currentItem: connection)
                                    }
                                }
                        }
                    } else {
                        UserCard(connection: UserConnection.dummy)
                            .redacted(reason: .placeholder)
                            .task {
                                await vm.getFollowers(.refresh)
                            }
                        ForEach(1...20, id: \.self) { _ in
                            UserCard(connection: UserConnection.dummy)
                                .redacted(reason: .placeholder)
                        }
                    }
                case .followings:
                    if let connections = vm.followings {
                        ForEach(connections) { connection in
                            UserCard(connection: connection)
                                .onAppear {
                                    Task {
                                        await vm.loadMore(type: .followings, currentItem: connection)
                                    }
                                }
                        }
                    } else {
                        UserCard(connection: UserConnection.dummy)
                            .redacted(reason: .placeholder)
                            .task {
                                await vm.getFollowings(.refresh)
                            }
                        ForEach(21...40, id: \.self) { _ in
                            UserCard(connection: UserConnection.dummy)
                                .redacted(reason: .placeholder)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .scrollIndicators(.hidden)
            .refreshable {
                Task {
                    switch activeTab {
                    case .followers:
                        await vm.getFollowers(.refresh)
                    case .followings:
                        await vm.getFollowings(.refresh)
                    }
                }
            }
        }
        .navigationTitle("Connections")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                if !vm.loadingSections.isEmpty {
                    ProgressView()
                        .transition(.opacity)
                        .animation(.easeInOut, value: vm.loadingSections.isEmpty)
                }
            }
        }
    }
}

fileprivate struct UserCard: View {
    let connection: UserConnection
    
    var body: some View {
        HStack(spacing: 10) {
            ProfileImage(connection.user.profileImage, size: 46, cornerRadius: 10)
            
            VStack(spacing: 0) {
                HStack(spacing: 5) {
                    LevelView(level: connection.user.progress.level)
                        .frame(width: 20, height: 24)
                    
                    Text(connection.user.name)
                        .cfont(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text("@" + connection.user.username)
                    .cfont(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            AppData.shared.goToUser(connection.user.id)
        }
    }
}

#Preview {
    MyConnections(activeTab: .followers)
}
