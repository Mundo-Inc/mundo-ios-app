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
    
    @StateObject var page: Page = .first()
    
    @State var isMute = false
    
    var body: some View {
        ZStack {
            GeometryReader(content: { geometry in
                ZStack {
                    Pager(page: page, data: vm.items) { item in
                        ForYouItem(data: item, itemIndex: vm.items.firstIndex(of: item), page: page, isMute: $isMute, commentsViewModel: commentsViewModel, parentGeometry: geometry)
                    }
                    .pagingPriority(.simultaneous)
                    .vertical()
                    .singlePagination(ratio: 0.5, sensitivity: .custom(0.2))
                    .onPageChanged({ pageIndex in
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
    }
}

#Preview {
    ForYouView(commentsViewModel: CommentsViewModel())
}
