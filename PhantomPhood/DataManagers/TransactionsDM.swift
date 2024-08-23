//
//  TransactionsDM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/26/24.
//

import Foundation

struct TransactionsDM {
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    func getCustomerEphemeralKey() async throws -> CustomerEphemeralKey {
        let token = try await auth.getToken()
        
        let data: APIResponse<CustomerEphemeralKey> = try await apiManager.requestData("/transactions/customer", method: .get, token: token)
        
        return data.data
    }
    
    func sendGift(amount: Double, to userId: String, using paymentMethod: String, message: String? = nil) async throws {
        let token = try await auth.getToken()
        
        struct RequestBody: Encodable {
            let amount: Double
            let receiverId: String
            let paymentMethodId: String
            let message: String?
        }
        
        let body = try apiManager.createRequestBody(RequestBody(amount: amount, receiverId: userId, paymentMethodId: paymentMethod, message: message))
        try await apiManager.requestNoContent("/transactions/gift", method: .post, body: body, token: token)
    }
    
    func getTransaction(withId id: String) async throws -> Transaction {
        let token = try await auth.getToken()
        
        let data: APIResponse<Transaction> = try await apiManager.requestData("/transactions/\(id)", method: .get, token: token)
        
        return data.data
    }
    
    // MARK: Structs
    
    struct CustomerEphemeralKey: Decodable {
        let customer: String
        let ephemeralKeySecret: String
    }
}
