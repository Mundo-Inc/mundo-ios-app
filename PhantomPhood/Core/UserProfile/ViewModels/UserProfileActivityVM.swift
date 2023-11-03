//
//  UserProfileActivityVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import Foundation
import Combine

@MainActor
class UserProfileActivityVM: ObservableObject {
    let userId: String
    private var cancellable = [AnyCancellable]()
    
    init(userId: String) {
        self.userId = userId
        $activityType
            .sink { newValue in
                Task {
                    await self.getActivities(.refresh)
                }
            }
            .store(in: &cancellable)
    }
    
    private let auth = Authentication.shared
    private let apiManager = APIManager()
    
    @Published var activityType: ProfileActivityVm.FeedItemActivityType = .all
    @Published var isLoading = false
    @Published var data: [FeedItem]? = nil
    @Published var total: Int? = nil
    
    var page = 1
            
    func getActivities(_ type: RefreshNewAction) async {
        guard let token = auth.token else { return }
        
        if type == .refresh {
            self.page = 1
            self.total = nil
        } else {
            if let data, let total, data.count >= total {
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
            let data = try await apiManager.requestData("/users/\(userId)/userActivities?page=\(self.page)\(activityType == .all ? "" : "&type=\(activityType.rawValue)")", method: .get, token: token) as RequestResponse?
            
            if let data {
                switch type {
                    
                case .refresh:
                    self.data = data.data
                case .new:
                    if self.data != nil {
                        self.data!.append(contentsOf: data.data)
                    } else {
                        self.data = data.data
                    }
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
        if let data {
            let thresholdIndex = data.index(data.endIndex, offsetBy: -5)
            if data.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                await getActivities(.new)
            }
        }
    }
}
