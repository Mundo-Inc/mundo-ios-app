//
//  FeedView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var appData = AppData.shared
    
    @ObservedObject var commentsViewModel = CommentsVM.shared
    @ObservedObject var mediasViewModel: MediasVM
    
    @StateObject var vm = FeedVM()
    
    var body: some View {
        ZStack {
            Color.themeBG
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    Color.clear
                        .frame(width: 0, height: 0)
                        .id(1)
                    
                    if !vm.isLoading && vm.items.isEmpty {
                        Text("Everyone starts somewhere! Why not with our rockstar CEO, Nabeel? 🎸")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom(style: .body))
                            .padding(.top)
                            .padding(.horizontal)
                            .onAppear {
                                if vm.nabeel == nil {
                                    Task {
                                        await vm.getNabeel()
                                    }
                                }
                            }
                        
                        HStack(spacing: 15) {
                            ProfileImage(vm.nabeel?.profileImage, size: 100, cornerRadius: 15)
                            
                            VStack {
                                VStack {
                                    Text(vm.nabeel?.name ?? "Nabeel")
                                        .font(.custom(style: .title2))
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("@\(vm.nabeel?.username ?? "Username")")
                                        .font(.custom(style: .headline))
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Group {
                                    if let isFollowing = vm.isFollowingNabeel {
                                        if !isFollowing {
                                            Button {
                                                Task {
                                                    await vm.followNabeel()
                                                }
                                            } label: {
                                                Text(vm.isRequestingFollow ? "Requesting" : "Follow")
                                                    .frame(maxWidth: .infinity)
                                            }
                                            .buttonStyle(BorderedProminentButtonStyle())
                                            .disabled(vm.isRequestingFollow)
                                        } else {
                                            Button {
                                                print("Unexpected")
                                            } label: {
                                                Text("Hmm, You already follow him!")
                                                    .frame(maxWidth: .infinity)
                                            }
                                            .buttonStyle(BorderedProminentButtonStyle())
                                            .disabled(vm.isRequestingFollow)
                                        }
                                    } else {
                                        Button {} label: {
                                            Text("Loading")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(BorderedButtonStyle())
                                        .disabled(vm.isRequestingFollow)
                                    }
                                }
                                .font(.custom(style: .footnote))
                                .controlSize(.small)
                            }
                        }
                        .padding(.horizontal)
                        .redacted(reason: vm.nabeel == nil ? .placeholder : [])
                        
                    } else {
                        Color.clear
                            .frame(width: 0, height: 0)
                            .fullScreenCover(isPresented: $mediasViewModel.show, content: {
                                MediasView(vm: mediasViewModel)
                            })
                        
                        LazyVStack(spacing: 20) {
                            ForEach(vm.items.indices, id: \.self) { index in
                                Group {
                                    switch vm.items[index].activityType {
                                    case .levelUp:
                                        FeedLevelUpView(data: vm.items[index], addReaction: vm.addReaction, removeReaction: vm.removeReaction)
                                    case .following:
                                        FeedFollowingView(data: vm.items[index], addReaction: vm.addReaction, removeReaction: vm.removeReaction)
                                    case .newReview:
                                        FeedReviewView(data: vm.items[index], addReaction: vm.addReaction, removeReaction: vm.removeReaction, mediasViewModel: mediasViewModel)
                                    case .newCheckin:
                                        FeedCheckinView(data: vm.items[index], addReaction: vm.addReaction, removeReaction: vm.removeReaction)
                                    default:
                                        EmptyView()
                                    }
                                }
                                .padding(.horizontal)
                                .onAppear {
                                    if !vm.isLoading {
                                        Task {
                                            await vm.loadMore(currentIndex: index)
                                        }
                                    }
                                }
                                
                                Divider()
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if vm.isLoading {
                            ProgressView()
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    Task {
                        if !vm.isLoading {
                            await vm.getFeed(.refresh)
                        }
                    }
                }
                .onChange(of: appData.tappedTwice) { tapped in
                    if tapped == .home {
                        withAnimation {
                            proxy.scrollTo(1)
                        }
                        appData.tappedTwice = nil
                        Task {
                            if !vm.isLoading {
                                HapticManager.shared.impact(style: .light)
                                await vm.getFeed(.refresh)
                                HapticManager.shared.notification(type: .success)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView(mediasViewModel: MediasVM())
    }
}
