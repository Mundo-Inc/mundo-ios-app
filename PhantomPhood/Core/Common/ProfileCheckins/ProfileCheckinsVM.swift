//
//  ProfileCheckinsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import Foundation

@MainActor
class ProfileCheckinsVM: ObservableObject {
    private let checkInDM = CheckInDM()
    
    @Published var isLoading = false
    @Published var checkIns: [Checkin]? = nil
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
    
    private var checkInsPagination: Pagination? = nil
    
    private let userId: UserIdEnum?
    
    init(userId: UserIdEnum?) {
        self.userId = userId
        
        Task {
            await self.getCheckins(type: .refresh)
        }
    }
    
    func getCheckins(type: RefreshNewAction) async {
        let uid: String? = switch userId {
        case .currentUser:
            Authentication.shared.currentUser?.id
        case .withId(let theId):
            theId
        case nil:
            nil
        }
        
        guard let uid else { return }
        
        if type == .refresh {
            checkInsPagination = nil
            self.total = nil
        } else if let checkInsPagination, !checkInsPagination.hasMore {
            return
        }
        
        self.isLoading = true
        
        do {
            let page = if let checkInsPagination {
                checkInsPagination.page + 1
            } else {
                1
            }
            
            let data = try await checkInDM.getCheckins(user: uid, page: page, limit: 500)
            
            switch type {
                
            case .refresh:
                self.checkIns = data.data
            case .new:
                if self.checkIns != nil {
                    self.checkIns!.append(contentsOf: data.data)
                } else {
                    self.checkIns = data.data
                }
            }
            
            self.checkInsPagination = data.pagination
            self.total = data.pagination.totalCount
        } catch {
            presentErrorToast(error)
        }
        
        self.isLoading = false
    }
}
