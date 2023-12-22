//
//  UserActivityView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/14/23.
//

import SwiftUI

struct UserActivityView: View {
    let id: String
    
    @StateObject var vm = UserActivityVM()
    
    @ObservedObject private var commentsViewModel = CommentsViewModel.shared
    @StateObject private var mediasViewModel = MediasViewModel()
    
    @State private var reportId: String? = nil
    
    var body: some View {
        ZStack {
            Color.themeBG
                .ignoresSafeArea()
                .fullScreenCover(isPresented: $mediasViewModel.show, content: {
                    MediasView(vm: mediasViewModel)
                })
                .onAppear {
                    Task {
                        await vm.getActivity(id)
                    }
                }
            
            ScrollView {
                if let item = vm.activity {
                    Group {
                        switch item.activityType {
                        case .levelUp:
                            FeedLevelUpView(data: item)
                        case .following:
                            FeedFollowingView(data: item)
                        case .newReview:
                            FeedReviewView(data: item, mediasViewModel: mediasViewModel, reportId: $reportId)
                        case .newCheckin:
                            FeedCheckinView(data: item)
                        default:
                            Text(item.activityType.rawValue)
                        }
                    }
                    .padding(.horizontal)
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
                        await vm.getActivity(id)
                    }
                }
            }
        }
    }
}

#Preview {
    UserActivityView(id: "Test")
}
