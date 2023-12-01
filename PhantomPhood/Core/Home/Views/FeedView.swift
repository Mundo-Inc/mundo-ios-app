//
//  FeedView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var commentsViewModel: CommentsViewModel
    @ObservedObject var mediasViewModel: MediasViewModel
    
    @StateObject var vm = FeedViewModel()
    
    @Binding var reportId: String?
    
    var body: some View {
        ZStack {
            Color.themeBG.ignoresSafeArea()
            
            ScrollView {
                if !vm.isLoading && vm.feedItems.isEmpty {
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
                        ForEach(vm.feedItems) { item in
                            Group {
                                switch item.activityType {
                                case .levelUp:
                                    FeedLevelUpView(data: item, commentsViewModel: commentsViewModel)
                                case .following:
                                    FeedFollowingView(data: item, commentsViewModel: commentsViewModel)
                                case .newReview:
                                    FeedReviewView(data: item, commentsViewModel: commentsViewModel, mediasViewModel: mediasViewModel, reportId: $reportId)
                                case .newCheckin:
                                    FeedCheckinView(data: item, commentsViewModel: commentsViewModel)
                                default:
                                    Text(item.activityType.rawValue)
                                }
                            }
                            .padding(.horizontal)
                            .onAppear {
                                if !vm.isLoading {
                                    Task {
                                        await vm.loadMore(currentItem: item)
                                    }
                                }
                            }
                            
                            Divider()
                        }
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.isLoading {
                        ProgressView()
                    }
                }
            })
            .scrollIndicators(.hidden)
            .refreshable {
                Task {
                    if !vm.isLoading {
                        await vm.getFeed(.refresh)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView(commentsViewModel: CommentsViewModel(), mediasViewModel: MediasViewModel(), reportId: .constant(nil))
            .environmentObject(SearchViewModel())
    }
}
