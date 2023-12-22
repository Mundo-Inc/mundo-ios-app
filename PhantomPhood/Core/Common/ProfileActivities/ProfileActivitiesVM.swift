//
//  ProfileActivityVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import Foundation

@MainActor
class ProfileActivitiesVM: ObservableObject {
    private let auth = Authentication.shared
    private let apiManager = APIManager.shared
    
    enum FeedItemActivityType: String, Decodable, CaseIterable {
        case all = "ALL"
        case newCheckin = "NEW_CHECKIN"
        case newReview = "NEW_REVIEW"
        case newRecommend = "NEW_RECOMMEND"
        case addPlace = "ADD_PLACE"
        case gotBadge = "GOT_BADGE"
        case levelUp = "LEVEL_UP"
        case following = "FOLLOWING"
        
        var title: String {
            switch self {
            case .all:
                "All"
            case .newCheckin:
                "Check-ins"
            case .newReview:
                "Reviews"
            case .newRecommend:
                "Recommendations"
            case .addPlace:
                "Places Added"
            case .gotBadge:
                "New Badges"
            case .levelUp:
                "Level Ups!"
            case .following:
                "Follow Activities"
            }
        }
    }

    @Published var activityType: FeedItemActivityType
    @Published var isactivityTypePresented = false
    @Published var isLoading = false
    @Published var data: [FeedItem] = []
    @Published var total: Int? = nil
    
    private let userId: UserIdEnum?
    
    init(userId: UserIdEnum?, activityType: FeedItemActivityType) {
        self.userId = userId
        self.activityType = activityType
        
        Task {
            await self.getActivities(.refresh)
        }
    }
    
    var page = 1
    
    func getActivities(_ type: RefreshNewAction) async {
        var uid: String?
        
        switch userId {
        case .currentUser:
            uid = auth.currentUser?.id
        case .withId(let theId):
            uid = theId
        case nil:
            uid = nil
        }
        
        guard let token = await auth.getToken(), let uid else { return }
        
        if type == .refresh {
            self.page = 1
            self.total = nil
        } else {
            if let total, data.count >= total {
                return
            }
        }
        
        self.isLoading = true
        
        do {
            struct RequestResponse: Decodable {
                let success: Bool
                let data: [FeedItem]
                let total: Int
            }
            let data = try await apiManager.requestData("/users/\(uid)/userActivities?page=\(self.page)\(activityType == .all ? "" : "&type=\(activityType.rawValue)")", method: .get, token: token) as RequestResponse?
            
            if let data {
                switch type {
                    
                case .refresh:
                    self.data = data.data
                case .new:
                    self.data.append(contentsOf: data.data)
                }
                
                self.total = data.total
                self.page += 1
            }
        } catch {
            print(error)
        }
        
        self.isLoading = false
    }
    
    func loadMore(currentItem item: FeedItem) async {
        let thresholdIndex = data.index(data.endIndex, offsetBy: -5)
        if data.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            await getActivities(.new)
        }
    }
}
