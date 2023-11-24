//
//  ForYouView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/15/23.
//

import SwiftUI
import SwiftUIPager

struct ForYouView: View {
    @ObservedObject var commentsViewModel: CommentsViewModel
    @StateObject var vm = ForYouViewModel()
    
    @StateObject private var page: Page = .first()
    
    @State private var isMute = false
    @State private var playId: String? = nil
    
    var body: some View {
        ZStack {
            GeometryReader(content: { geometry in
                ZStack {
                    Pager(page: page, data: vm.items) { item in
                        ForYouItem(data: item, itemIndex: vm.items.firstIndex(of: item), page: page, isMute: $isMute, commentsViewModel: commentsViewModel, parentGeometry: geometry, playId: $playId)
                    }
                    .pagingPriority(.simultaneous)
                    .vertical()
                    .singlePagination(ratio: 0.5, sensitivity: .custom(0.2))
                    .onPageChanged({ pageIndex in
                        // set playId
                        if page.index >= 0 && vm.items.count >= pageIndex + 1 {
                            switch vm.items[pageIndex].resource {
                            case .review(let feedReview):
                                if let first = feedReview.videos.first {
                                    playId = first.id
                                } else {
                                    playId = nil
                                }
                            default:
                                break
                            }
                        }
                                                
                        guard pageIndex >= vm.items.count - 5 else { return }
                        
                        if !vm.isLoading {
                            Task {
                                await vm.getForYou(.new)
                            }
                        }
                    })
                }
                .ignoresSafeArea(edges: .top)
            })
        }
        .onDisappear {
            self.playId = nil
        }
        .onAppear {
            if page.index >= 0 && vm.items.count >= page.index + 1 {
                switch vm.items[page.index].resource {
                case .review(let feedReview):
                    if let first = feedReview.videos.first {
                        playId = first.id
                    } else {
                        playId = nil
                    }
                default:
                    break
                }
            }
        }
    }
}

#Preview {
    ForYouView(commentsViewModel: CommentsViewModel())
}
