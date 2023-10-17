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
            .scrollIndicators(.hidden)
            .navigationTitle("Home")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if vm.isLoading {
                        ProgressView()
                    }
                }
                
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        searchViewModel.showSearch = true
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                    }
//                    .sheet(isPresented: $searchViewModel.showSearch, onDismiss: {
//                        searchViewModel.tokens.removeAll()
//                        searchViewModel.text = ""
//                        dismissSearch()
//                    }) {
//                        SearchView { place in
//                            appData.homeNavStack.append(HomeStack.place(id: place.id, action: searchViewModel.tokens.contains(.addReview) ? .addReview : searchViewModel.tokens.contains(.checkin) ? .checkin : nil))
//                        } onUserSelect: { user in
//                            appData.homeNavStack.append(HomeStack.userProfile(id: user.id))
//                        }
//                    }
//                }
                
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
    }
}
