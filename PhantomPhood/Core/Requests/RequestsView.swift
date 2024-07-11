//
//  RequestsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/9/24.
//

import SwiftUI

struct RequestsView: View {
    @ObservedObject private var notificationsVM = NotificationsVM.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(notificationsVM.followRequests) { request in
                    HStack {
                        ProfileImage(request.user.profileImage, size: 50)
                            .onTapGesture {
                                AppData.shared.goTo(.userProfile(userId: request.user.id))
                            }
                        
                        VStack(alignment: .leading) {
                            Text(request.user.name)
                                .fontWeight(.semibold)
                            
                            Text("@\(request.user.username)")
                                .cfont(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture {
                            AppData.shared.goTo(.userProfile(userId: request.user.id))
                        }
                        
                        Group {
                            if let connectionStatus = request.user.connectionStatus {
                                let isLoadingA = notificationsVM.loadingSections.contains(.acceptingRequest(request.id))
                                let isLoadingR = notificationsVM.loadingSections.contains(.rejectingRequest(request.id))
                                let isLoadingF = notificationsVM.loadingSections.contains(.followRequest(request.id))
                                
                                switch connectionStatus.followedByStatus {
                                case .requested:
                                    Button {
                                        Task {
                                            await notificationsVM.acceptRequest(for: request.id)
                                        }
                                    } label: {
                                        Text("Confirm".uppercased())
                                            .frame(height: 28)
                                            .padding(.horizontal, 10)
                                            .overlay {
                                                if isLoadingA {
                                                    ProgressView()
                                                }
                                            }
                                            .foregroundStyle(isLoadingA ? Color.clear : Color.black)
                                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 6))
                                    }
                                    .disabled(isLoadingA || isLoadingR)
                                    
                                    Button {
                                        Task {
                                            await notificationsVM.rejectRequest(for: request.id)
                                        }
                                    } label: {
                                        Text("Decline".uppercased())
                                            .frame(height: 28)
                                            .padding(.horizontal, 10)
                                            .overlay {
                                                if isLoadingR {
                                                    ProgressView()
                                                }
                                            }
                                            .foregroundStyle(isLoadingR ? Color.clear : Color.white)
                                            .background(Color.themeBorder, in: RoundedRectangle(cornerRadius: 6))
                                    }
                                    .disabled(isLoadingA || isLoadingR)
                                case .following:
                                    switch connectionStatus.followingStatus {
                                    case .notFollowing:
                                        Button {
                                            Task {
                                                await notificationsVM.follow(user: request.user.id)
                                            }
                                        } label: {
                                            HStack {
                                                if isLoadingF {
                                                    ProgressView()
                                                } else {
                                                    Text("Follow Back".uppercased())
                                                }
                                            }
                                            .frame(height: 28)
                                            .padding(.horizontal, 10)
                                            .foregroundStyle(Color.black)
                                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 6))
                                        }
                                        .disabled(isLoadingF)
                                    case .requested:
                                        Text("Requested".uppercased())
                                            .frame(height: 28)
                                            .padding(.horizontal, 10)
                                            .foregroundStyle(Color.white)
                                            .background(Color.themeBorder, in: RoundedRectangle(cornerRadius: 6))
                                    case .following:
                                        Text("Following")
                                            .frame(height: 28)
                                            .padding(.horizontal, 10)
                                            .foregroundStyle(Color.white)
                                            .background(Color.themeBorder, in: RoundedRectangle(cornerRadius: 6))
                                    }
                                case .notFollowing:
                                    Text("Declined".uppercased())
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        .cfont(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    Divider()
                }
            }
        }
        .task {
            await notificationsVM.getFollowRequests(.refresh)
        }
        .navigationTitle("Follow Requests")
        .toolbar {
            if let followRequestsCount = notificationsVM.followRequestsCount {
                ToolbarItem(placement: .topBarTrailing) {
                    Text(followRequestsCount > 99 ? "99+" : "\(followRequestsCount)")
                        .frame(minWidth: 30, minHeight: 30)
                        .background(Color.themePrimary, in: Circle())
                }
            }
        }
    }
}

#Preview {
    RequestsView()
}
