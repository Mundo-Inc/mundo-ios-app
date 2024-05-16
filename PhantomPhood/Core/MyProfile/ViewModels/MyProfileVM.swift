//
//  MyProfileVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/16/24.
//

import Foundation

final class MyProfileVM: LoadingSections, ObservableObject {
    private let userActivityDM = UserActivityDM()
    
    @Published var loadingSections = Set<LoadingSection>()
    
    @Published var activeTab: Tab = .posts
    
    @Published var posts: [FeedItem] = []
    
    @Published var presentedSheet: Sheet? = nil
    
    private var userPostsPagination: Pagination? = nil
    func getPosts(_ requestType: RefreshNewAction) async {
        guard let id = Authentication.shared.currentUser?.id, !loadingSections.contains(.gettingPosts) else { return }
        
        if requestType == .refresh {
            userPostsPagination = nil
        } else if let userPostsPagination, !userPostsPagination.hasMore {
            return
        }
        
        setLoadingState(.gettingPosts, to: true)
        do {
            let page = (userPostsPagination?.page ?? 0) + 1
            
            let result = try await userActivityDM.getUserActivities(id, page: page, activityTypes: [.newCheckin, .newReview, .newHomemade], limit: 21)
            
            userPostsPagination = result.pagination
            
            await MainActor.run {
                if requestType == .new {
                    self.posts.append(contentsOf: result.data)
                } else {
                    self.posts = result.data
                }
            }
        } catch {
            presentErrorToast(error)
        }
        setLoadingState(.gettingPosts, to: false)
    }
    
    func loadMorePosts(currentItem: FeedItem) async {
        guard !loadingSections.contains(.gettingPosts) else { return }
        
        let thresholdIndex = posts.index(posts.endIndex, offsetBy: -3)
        if posts.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            await getPosts(.new)
        }
    }
    
    // MARK: Enums
    
    enum Tab: Hashable, CaseIterable {
        case posts
        case achievements
        case lists
        case gifts
        
        var title: String {
            switch self {
            case .posts:
                return "Posts"
            case .achievements:
                return "Achievements"
            case .lists:
                return "Lists"
            case .gifts:
                return "Gifts"
            }
        }
        
        var iconSystemName: String {
            switch self {
            case .posts:
                return "app.connected.to.app.below.fill"
            case .achievements:
                return "crown"
            case .lists:
                return "list.star"
            case .gifts:
                return "gift"
            }
        }
    }
    
    enum LoadingSection: Hashable {
        case gettingPosts
    }
    
    enum Sheet: String, Identifiable, Hashable {
        case editProfile
        
        var id: String {
            return self.rawValue
        }
    }
}
