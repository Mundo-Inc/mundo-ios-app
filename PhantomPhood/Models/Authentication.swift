//
//  Authentication.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12.09.2023.
//

import Foundation
//import Combine

enum Role: String, Codable {
    case user
    case admin
}

struct CurrentUserCoreData: Codable, Identifiable {
    let _id, name, username, profileImage: String
    let bio: String?
    let email: Email
    let coins: Int
    let role: Role
    let verified: Bool
    let progress: UserProgress
    
    struct Email: Codable {
        let address: String
        let verified: Bool
    }
    
    var id: String {
        self._id
    }
}

struct CurrentUserFullData: Codable {
    let _id, name, username, profileImage: String
    var bio: String?
    let email: Email
    let rank, remainingXp, coins, reviewsCount, followersCount, followingCount, totalCheckins: Int
    let role: Role
    let verified: Bool
    let progress: UserProgress
    
    struct Email: Codable {
        let address: String
        let verified: Bool
    }
    
    var id: String {
        self._id
    }
}

@MainActor
class Authentication: ObservableObject {
    
    static let shared = Authentication()
    
    private let appData = AppData.shared
    
    // MARK: - API Manager
    
    private let apiManager = APIManager()
    
    // MARK: - Internal Structs
    
    struct SignUpData: Codable {
        let userId: String
        let token: String
    }
    
    typealias SignInData = SignUpData
    
    // MARK: - Properties
    
    @Published private(set) var user: CurrentUserFullData? = nil
    @Published private(set) var isSignedIn: Bool = false
    
    @Published private(set) var userId: String? = nil
    
    var token: String? {
        // get jwt token from Keychain
        let tk = KeychainHelper.getData(for: .userToken)
        return tk
    }
    
    // MARK: - INIT
    
    init() {
        let uId = UserDefaults.standard.string(forKey: "userId")
        if let uId, let _ = token {
            self.userId = uId
            self.isSignedIn = true
        }
        
        Task {
            await self.updateUserInfo()
        }
        
    }
    
    // MARK: - Public Methods
    
    func signin(email: String, password: String) async throws -> SignInData? {
        struct SignInRequestBody: Encodable {
            let action: String
            let email: String
            let password: String
        }
        
        let reqBody = try apiManager.createRequestBody(SignInRequestBody(action: "signin", email: email, password: password))
        
        let data = try await apiManager.requestData("/auth", method: .post, body: reqBody) as SignInData?
        
        self.isSignedIn = true
        if let data {
            self.userId = data.userId
            let isSaved = KeychainHelper.save(data: data.token, for: .userToken)
            if !isSaved {
                self.signout()
                throw CancellationError()
            }
            UserDefaults.standard.set(data.userId, forKey: "userId")
        }
        await self.updateUserInfo()
        
        return data
    }
    
    func signup(name: String, email: String, password: String, username: String?) async throws -> SignUpData? {
        struct SignUpRequestBody: Encodable {
            let name: String
            let email: String
            let password: String
            let username: String?
        }
        
        let reqBody = try apiManager.createRequestBody(SignUpRequestBody(name: name, email: email, password: password, username: username))
        
        let data = try await apiManager.requestData("/users", method: .post, body: reqBody) as SignUpData?
        
        self.isSignedIn = true
        if let data {
            self.userId = data.userId
            let isSaved = KeychainHelper.save(data: data.token, for: .userToken)
            if !isSaved {
                self.signout()
                throw CancellationError()
            }
            UserDefaults.standard.set(data.userId, forKey: "userId")
        }
        await self.updateUserInfo()
        
        return data
    }
    
    func signout() {
        self.isSignedIn = false
        let _ = KeychainHelper.deleteData(for: .userToken)
        UserDefaults.standard.removeObject(forKey: "userId")
        self.userId = nil
        self.user = nil
        appData.reset()
    }
    
    func updateUserInfo() async {
        struct UserResponse: Codable {
            let success: Bool
            let data: CurrentUserFullData
        }

        if let userId, let token {
            do {
                let data = try await apiManager.requestData("/users/\(userId)", method: .get, token: token) as UserResponse?
                
                if let data {
                    self.user = data.data
                    
                    await setDeviceToken()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func setDeviceToken() async {
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
        
        guard let token, let user, let deviceToken, !deviceToken.isEmpty else {
            return
        }
        
        struct RequestBody: Encodable {
            let action = "deviceToken"
            let platform = "ios"
            let token: String
        }
        
        do {
            let body = try apiManager.createRequestBody(RequestBody(token: deviceToken))
            
            let _ = try await apiManager.requestNoContent("/users/\(user.id)/settings", method: .put, body: body, token: token)
            UserDefaults.standard.removeObject(forKey: "deviceToken")
        } catch {
            print(error)
        }
    }
}
