//
//  UserProfileCheckinsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import Foundation

@MainActor
class UserProfileCheckinsVM: ObservableObject {
    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    private let auth = Authentication.shared
    private let apiManager = APIManager()
    
    @Published var isLoading = false
    @Published var checkins: [Checkin]? = nil
    @Published var total: Int? = nil
    
    var page = 1
        
    func getCheckins(type: RefreshNewAction) async {
        guard let token = auth.token else { return }
        
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
            struct RequestResponse: Decodable {
                let success: Bool
                let data: [Checkin]
                let total: Int
            }
            let data = try await apiManager.requestData("/checkins?user=\(userId)&page=\(self.page)", method: .get, token: token) as RequestResponse?
            
            if let data {
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
                
                self.total = data.total
                self.page += 1
            }
        } catch {
            print(error)
        }
        
        self.isLoading = false
    }
}
