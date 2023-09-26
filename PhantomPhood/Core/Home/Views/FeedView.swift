//
//  FeedView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI

struct FeedView: View {
    @Environment(\.isSearching)
    private var isSearching: Bool
    
    @StateObject var vm = FeedViewModel()
    
    @Binding var searchText: String
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 50) {
                ForEach(vm.feedItems) { item in
                    switch item.activityType {
                    case .levelUp:
                        FeedLevelUpView(data: item)
                    case .following:
                        FeedFollowingView(data: item)
                    case .newReview:
                        FeedReviewView(data: item)
                    default:
                        Text(item.activityType.rawValue)
                        EmptyView()
                    }
                }
                if vm.isLoading {
                    ProgressView()
                }
                Color.clear
                    .frame(width: 0, height: 0, alignment: .bottom)
                    .onAppear {
                        print("Attempt to load")
                        if !vm.isLoading {
                            print("Loading More Feed")
                            Task {
                                await vm.getFeed()
                            }
                        }
                    }
            }.padding(.horizontal)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
//        .overlay {
//            if isSearching && !searchText.isEmpty {
//                ScrollView {
//                    VStack {
//                        Text("Searching for \(searchText)")
//                        
//                        RoundedRectangle(cornerRadius: 15)
//                            .frame(height: 50)
//                        RoundedRectangle(cornerRadius: 15)
//                            .frame(height: 50)
//                    }
//                }
//                .padding(.horizontal)
//                .background(.thinMaterial)
//            }
//        }
    }
}

#Preview {
    NavigationStack {
        FeedView(searchText: .constant("Test"))
    }
}
