//
//  TransactionsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/26/24.
//

import Foundation

final class TransactionsDM {
    private let apiManager = APIManager.shared
    private let auth: Authentication = Authentication.shared
    
    func getCustomerEphemeralKey() async throws -> CustomerEphemeralKey {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<CustomerEphemeralKey> = try await apiManager.requestData("/transactions/customer", method: .get, token: token)
        
        return data.data
    }
    
    // MARK: Structs
    
    struct CustomerEphemeralKey: Decodable {
        let customer: String
        let ephemeralKeySecret: String
    }
}
