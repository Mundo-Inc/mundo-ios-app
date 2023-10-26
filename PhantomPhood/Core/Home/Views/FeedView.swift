//
//  FeedView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI

struct FeedView: View {
    @Environment(\.dismissSearch) var dismissSearch
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject var searchViewModel: SearchViewModel
    
    @StateObject var commentsViewModel = CommentsViewModel()
    @StateObject var mediasViewModel = MediasViewModel()
    @StateObject var vm = FeedViewModel()
        
    var body: some View {
        ZStack {
            Color.themeBG.ignoresSafeArea()
                .sheet(isPresented: $searchViewModel.showSearch, onDismiss: {
                    searchViewModel.tokens.removeAll()
                    searchViewModel.text = ""
                    dismissSearch()
                }) {
                    SearchView(vm: searchViewModel) { place in
                        appData.homeNavStack.append(HomeStack.place(id: place.id, action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
                    } onUserSelect: { user in
                        appData.homeNavStack.append(HomeStack.userProfile(id: user.id))
                    }
                }
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
                        if let profileImage = vm.nabeel?.profileImage, let imageURL = URL(string: profileImage) {
                            CacheAsyncImage(url: imageURL) { phase in
                                switch phase {
                                case .empty:
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.tertiary)
                                        .overlay {
                                            ProgressView()
                                        }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                default:
                                    VStack(spacing: 0) {
                                        Image(systemName: "exclamationmark.icloud")
                                            .font(.system(size: 50))
                                            .foregroundStyle(.red)
                                            .frame(width: 50, height: 50)
                                        Text("Error")
                                            .font(.custom(style: .caption))
                                    }
                                    .background(Color.themeBG)
                                }
                            }
                            .frame(width: 100, height: 100)
                            .contentShape(Rectangle())
                            .clipShape(.rect(cornerRadius: 15))
                        } else {
                            // No Image
                            if vm.nabeel == nil {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(.tertiary)
                                    .frame(width: 100, height: 100)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.secondary)
                                    .frame(width: 100, height: 100)
                                    .background(Color.themeBG)
                                    .clipShape(.rect(cornerRadius: 15))
                            }
                        }
                        
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
                    LazyVStack(spacing: 20) {
                        ForEach(vm.feedItems) { item in
                            Group {
                                switch item.activityType {
                                case .levelUp:
                                    FeedLevelUpView(data: item, commentsViewModel: commentsViewModel)
                                case .following:
                                    FeedFollowingView(data: item, commentsViewModel: commentsViewModel)
                                case .newReview:
                                    FeedReviewView(data: item, commentsViewModel: commentsViewModel, mediasViewModel: mediasViewModel)
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
            .scrollIndicators(.hidden)
            .navigationTitle("Home")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.isLoading {
                        ProgressView()
                    }
                }
                                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: HomeStack.notifications) {
                        Image(systemName: "bell")
                    }
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                Task {
                    if !vm.isLoading {
                        await vm.getFeed(.refresh)
                    }
                }
            }
        }
        .sheet(isPresented: $commentsViewModel.showComments, content: {
            CommentsView(vm: commentsViewModel)
        })
        .fullScreenCover(isPresented: $mediasViewModel.show, content: {
            MediasView(vm: mediasViewModel)
        })
    }
}

#Preview {
    NavigationStack {
        FeedView()
            .environmentObject(AppData())
            .environmentObject(SearchViewModel())
    }
}
