//
//  ProfileActivity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import SwiftUI

struct ProfileActivity: View {
    @StateObject private var vm = ProfileActivityVm()
    @StateObject private var commentsViewModel = CommentsViewModel()
    @StateObject private var mediasViewModel = MediasViewModel()
    
    @State private var showActions: Bool = false
    @State private var reportId: String? = nil
    
    var body: some View {
        HStack {
            Text("Filter")
            
            Spacer()
            
            Picker("Filter", selection: $vm.activityType) {
                ForEach(ProfileActivityVm.FeedItemActivityType.allCases, id: \.self) { item in
                    Text(item.title).tag(item.rawValue)
                }
            }
        }
        .padding(.horizontal)
        .font(.custom(style: .body))
        .sheet(isPresented: $commentsViewModel.showComments, content: {
            CommentsView(vm: commentsViewModel)
        })
        .onAppear {
            Task {
                await vm.getActivities(.refresh)
            }
        }
        
        Spacer()
            .sheet(isPresented: Binding(optionalValue: $reportId)) {
                ReportView(id: $reportId, type: .review)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: reportId)
            }
        
        if vm.isLoading {
            ProgressView()
            Spacer()
        } else if let data = vm.data {
            if data.isEmpty {
                Text("No activity")
                    .font(.custom(style: .body))
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(data) { item in
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
    }
}

#Preview {
    ProfileActivity()
}
