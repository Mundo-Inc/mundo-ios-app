//
//  FeedView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI

struct FeedView: View {
    @Environment(\.isSearching) private var isSearching: Bool
    
    @StateObject var vm = FeedViewModel()
    
    @Binding var searchText: String
    
    var body: some View {
        ZStack {
            Color.themeBG.ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(vm.feedItems) { item in
                        Group {
                            switch item.activityType {
                            case .levelUp:
                                FeedLevelUpView(data: item)
                            case .following:
                                FeedFollowingView(data: item)
                            case .newReview:
                                FeedReviewView(data: item)
                            case .newCheckin:
                                FeedCheckinView(data: item)
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
            .overlay {
                if isSearching && !searchText.isEmpty {
                    ScrollView {
                        VStack {
                            Text("Searching for \(searchText)")
                            
                            RoundedRectangle(cornerRadius: 15)
                                .frame(height: 50)
                            RoundedRectangle(cornerRadius: 15)
                                .frame(height: 50)
                        }
                    }
                    .padding(.horizontal)
                    .background(.thinMaterial)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedView(searchText: .constant("Test"))
    }
}
