//
//  ProfileCheckinsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import Foundation

@MainActor
class ProfileCheckinsVM: ObservableObject {
    private let auth = Authentication.shared
    private let checkInDM = CheckInDM()
    
    @Published var isLoading = false
    @Published var checkins: [Checkin]? = nil
    @Published var total: Int? = nil
    
    @Published var displayMode: DisplayModeEnum = .map
    enum DisplayModeEnum: String, CaseIterable {
        case map = "Map"
        case list = "List"
        
        var systemImage: String {
            switch self {
            case .map:
                return "map.fill"
            case .list:
                return "list.dash"
            }
        }
    }
    
    var page = 1
    
    private let userId: UserIdEnum?
    
    init(userId: UserIdEnum?) {
        self.userId = userId
        
        Task {
            await self.getCheckins(type: .refresh)
        }
    }
    
    func getCheckins(type: RefreshNewAction) async {
        var uid: String?
        
        switch userId {
        case .currentUser:
            uid = auth.currentUser?.id
        case .withId(let theId):
            uid = theId
        case nil:
            uid = nil
        }
        
        guard let uid else { return }
        
        if type == .refresh {
            self.page = 1
            self.total = nil
        } else {
            if let checkins, let total, checkins.count >= total {
                return
            }
        }
        
        self.isLoading = true
        
        do {
            let data = try await checkInDM.getCheckins(user: uid, page: self.page)
            
            switch type {
                
            case .refresh:
                self.checkins = data.data
            case .new:
                if self.checkins != nil {
                    self.checkins!.append(contentsOf: data.data)
                } else {
                    self.checkins = data.data
                }
            }
            
            self.total = data.pagination.totalCount
            self.page += 1
        } catch {
            print(error)
        }
        
        self.isLoading = false
    }
}
