//
//  UserConnectionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/1/23.
//

import SwiftUI

struct UserConnectionsView: View {
    private let userId: String
    @State private var activeTab: UserConnectionsTab
    
    @StateObject private var vm = UserConnectionsVM()
    
    init(userId: String, activeTab: UserConnectionsTab = .followers) {
        self.userId = userId
        self._activeTab = State(wrappedValue: activeTab)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    withAnimation {
                        activeTab = .followers
                    }
                } label: {
                    Text("Followers")
                        .font(.custom(style: .footnote))
                        .bold()
                        .textCase(.uppercase)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundStyle(
                    activeTab == .followers ? Color.accentColor : Color.secondary
                )
                .padding(.trailing)
                
                Divider()
                    .frame(maxHeight: 30)
                
                Button {
                    withAnimation {
                        activeTab = .followings
                    }
                } label: {
                    Text("Followings")
                        .font(.custom(style: .footnote))
                        .bold()
                        .textCase(.uppercase)
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundStyle(
                    activeTab == .followings ? Color.accentColor : Color.secondary
                )
                .padding(.leading)
            }
            
            Divider()
                .padding(.top, 4)
            
            List {
                switch activeTab {
                case .followers:
                    if let connections = vm.followers {
                        ForEach(connections) { connection in
                            UserCard(connection: connection)
                                .onAppear {
                                    if !vm.isLoading {
                                        Task {
                                            await vm.loadMore(userId: userId, type: .followers, currentItem: connection)
                                        }
                                    }
                                }
                        }
                    } else {
                        UserCard(connection: UserConnection.dummy)
                            .redacted(reason: .placeholder)
                        UserCard(connection: UserConnection.dummy)
                            .redacted(reason: .placeholder)
                            .onAppear {
                                Task {
                                    await vm.getConnections(userId: userId, type: .followers, requestType: .refresh)
                                }
                            }
                    }
                case .followings:
                    if let connections = vm.followings {
                        ForEach(connections) { connection in
                            UserCard(connection: connection)
                                .onAppear {
                                    if !vm.isLoading {
                                        Task {
                                            await vm.loadMore(userId: userId, type: .followings, currentItem: connection)
                                        }
                                    }
                                }
                        }
                    } else {
                        UserCard(connection: UserConnection.dummy)
                            .redacted(reason: .placeholder)
                        UserCard(connection: UserConnection.dummy)
                            .redacted(reason: .placeholder)
                            .onAppear {
                                Task {
                                    await vm.getConnections(userId: userId, type: .followings, requestType: .refresh)
                                }
                            }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .scrollIndicators(.hidden)
            .refreshable {
                await vm.getConnections(userId: userId, type: activeTab == .followers ? .followers : .followings, requestType: .refresh)
            }
        }
        .navigationTitle("Connections")
        .toolbar {
            ToolbarItem {
                if vm.isLoading {
                    ProgressView()
                        .transition(.opacity)
                        .animation(.easeInOut, value: vm.isLoading)
                }
            }
        }
    }
}

fileprivate struct UserCard: View {
    let connection: UserConnection
    
    var body: some View {
        HStack(spacing: 10) {
            ProfileImage(connection.user.profileImage, size: 42, cornerRadius: 10)
            
            VStack(spacing: 0) {
                HStack {
                    LevelView(level: connection.user.progress.level)
                        .frame(width: 20, height: 26)
                    
                    Text(connection.user.name)
                        .font(.custom(style: .headline))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text("@" + connection.user.username)
                    .font(.custom(style: .subheadline))
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
    UserConnectionsView(userId: "645e7f843abeb74ee6248ced")
}
