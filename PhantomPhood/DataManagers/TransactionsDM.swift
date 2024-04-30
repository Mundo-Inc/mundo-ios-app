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
    
    func sendGift(amount: Double, to userId: String, using paymentMethod: String, message: String? = nil) async throws {
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
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
        guard let token = await auth.getToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let data: APIResponse<Transaction> = try await apiManager.requestData("/transactions/\(id)", method: .get, token: token)
        
        return data.data
    }
    
    // MARK: Structs
    
    struct CustomerEphemeralKey: Decodable {
        let customer: String
        let ephemeralKeySecret: String
    }
}
