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
    
    @StateObject private var vm = MyConnectionsViewModel()
    
    init(activeTab: UserConnectionsTab = .followers) {
        self._activeTab = State(wrappedValue: activeTab)
    }
    
    var body: some View {
        VStack {
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
            
            List {
                switch activeTab {
                case .followers:
                    if let connections = vm.followers {
                        ForEach(connections) { connection in
                            UserCard(connection: connection)
                                .onAppear {
                                    if !vm.isLoading {
                                        Task {
                                            await vm.loadMore(type: .followers, currentItem: connection)
                                        }
                                    }
                                }
                        }
                    } else {
                        ProgressView()
                            .onAppear {
                                Task {
                                    await vm.getConnections(type: .followers, requestType: .refresh)
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
                                            await vm.loadMore(type: .followings, currentItem: connection)
                                        }
                                    }
                                }
                        }
                    } else {
                        ProgressView()
                            .onAppear {
                                Task {
                                    await vm.getConnections(type: .followings, requestType: .refresh)
                                }
                            }
                    }
                }
            }
            .listStyle(.plain)
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
    
    var body: some View {
        NavigationLink(value: AppRoute.userProfile(userId: connection.user.id)) {
            HStack {
                ProfileImage(connection.user.profileImage, size: 46, cornerRadius: 10)
                
                VStack(spacing: 0) {
                    HStack {
                        LevelView(level: connection.user.progress.level)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 28)
                        
                        Text(connection.user.name)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("@" + connection.user.username)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 8)
                .font(.custom(style: .body))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    MyConnections(activeTab: .followers)
}
