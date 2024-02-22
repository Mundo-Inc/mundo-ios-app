//
//  MyConnections.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/31/23.
//

import SwiftUI
import Kingfisher

struct MyConnections: View {
    @State private var activeTab: UserConnectionsTab
    
    @ObservedObject private var appData = AppData.shared
    @ObservedObject private var auth = Authentication.shared
    
    @StateObject private var vm = MyConnectionsVM()
    
    init(activeTab: UserConnectionsTab = .followers) {
        self._activeTab = State(wrappedValue: activeTab)
    }
    
    func gotToUser(_ id: String) {
        appData.goToUser(id, auth.currentUser?.id)
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
                            UserCard(connection: connection, goToUser: gotToUser)
                                .onAppear {
                                    if !vm.isLoading {
                                        Task {
                                            await vm.loadMore(type: .followers, currentItem: connection)
                                        }
                                    }
                                }
                        }
                    } else {
                        UserCard(connection: UserConnection.dummy, goToUser: gotToUser)
                            .redacted(reason: .placeholder)
                        UserCard(connection: UserConnection.dummy, goToUser: gotToUser)
                            .redacted(reason: .placeholder)
                            .onAppear {
                                Task {
                                    await vm.getConnections(type: .followers, requestType: .refresh)
                                }
                            }
                    }
                case .followings:
                    if let connections = vm.followings {
                        ForEach(connections) { connection in
                            UserCard(connection: connection, goToUser: gotToUser)
                                .onAppear {
                                    if !vm.isLoading {
                                        Task {
                                            await vm.loadMore(type: .followings, currentItem: connection)
                                        }
                                    }
                                }
                        }
                    } else {
                        UserCard(connection: UserConnection.dummy, goToUser: gotToUser)
                            .redacted(reason: .placeholder)
                        UserCard(connection: UserConnection.dummy, goToUser: gotToUser)
                            .redacted(reason: .placeholder)
                            .onAppear {
                                Task {
                                    await vm.getConnections(type: .followings, requestType: .refresh)
                                }
                            }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .scrollIndicators(.hidden)
            .refreshable {
                await vm.getConnections(type: activeTab == .followers ? .followers : .followings, requestType: .refresh)
            }
        }
        .navigationTitle("Connections")
        .toolbar(content: {
            ToolbarItem {
                if vm.isLoading {
                    ProgressView()
                        .transition(.opacity)
                        .animation(.easeInOut, value: vm.isLoading)
                }
            }
        })
    }
}

fileprivate struct UserCard: View {
    let connection: UserConnection
    let goToUser: (String) -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            ProfileImage(connection.user.profileImage, size: 42, cornerRadius: 10)
            
            VStack(spacing: 0) {
                HStack {
                    LevelView(level: connection.user.progress.level)
                        .aspectRatio(contentMode: .fit)
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
            goToUser(connection.user.id)
        }
    }
}

#Preview {
    MyConnections(activeTab: .followers)
}
