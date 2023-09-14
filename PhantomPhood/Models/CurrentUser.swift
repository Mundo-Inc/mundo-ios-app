//
//  CurrentUser.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 14.09.2023.
//

import Foundation


@MainActor
class CurrentUser: ObservableObject {
    
    // MARK: - Classes
    
    private let apiManager = APIManager()
    
    // MARK: - Properties
    
    @Published private(set) var info: CurrentUserData? = nil
    
    // MARK: - Public Methods
    
    func updateInfo(userId: String, token: String) async {
        struct UserResponse: Codable {
            let success: Bool
            let data: CurrentUserData
        }
        
        do {
            print("\n\nGetting User Data\n\n")
            let (data, response) = try await apiManager.request("/users/\(userId)", method: .get, token: token) as (UserResponse?, HTTPURLResponse)
            
            if let data {
                print(data)
            } else {
                print("\n\nNo Data\n\n")
            }
            
            
            guard let data, response.statusCode >= 200, response.statusCode < 300 else { return }

            self.info = data.data

        } catch {
            print(error)
        }
    }
}
