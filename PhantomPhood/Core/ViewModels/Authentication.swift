//
//  Authentication.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12.09.2023.
//

import Foundation
import Firebase
import GoogleSignIn
import FirebaseAuth

enum UserRole: String, Codable {
    case user
    case admin
}

struct CurrentUserCoreData: Codable, Identifiable {
    let _id, name, username, profileImage: String
    let bio: String?
    let email: Email
    let coins: Int
    let role: UserRole
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
    let role: UserRole
    let verified: Bool
    let progress: UserProgress
    let accepted_eula: String?
    
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
    private let apiManager = APIManager.shared
    
    // MARK: - Properties
    
    @Published private(set) var userSession: Firebase.User?
    @Published private(set) var currentUser: CurrentUserFullData? = nil
    
    // MARK: - INIT
    
    private init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await updateUserInfo()
        }
    }
    
    // MARK: - Public Methods
    
    func getToken() async -> String? {
        do {
            let token = try await Auth.auth().currentUser?.getIDToken()
            return token
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func signin(email: String, password: String) async -> (success: Bool, error: String?, errorCode: Int?) {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            do {
                guard let uid = Auth.auth().currentUser?.uid, let token = await getToken() else {
                    throw URLError(.userAuthenticationRequired)
                }
                let user = try await getUserInfo(uid: uid, token: token)
                self.userSession = result.user
                self.currentUser = user
                await setDeviceToken()
                return (true, nil, nil)
            } catch {
                print("DEBUG: Couldn't get user info | Error: \(error.localizedDescription)")
                return (false, "Couldn't get user info", nil)
            }
        } catch {
            return (false, "Email/Password is incorrect", 400)
        }
    }
    
    @discardableResult
    func signin(credential: AuthCredential) async -> (success: Bool, error: String?, errorCode: Int?) {
        do {
            let result = try await Auth.auth().signIn(with: credential)
            do {
                guard let uid = Auth.auth().currentUser?.uid, let token = await getToken() else {
                    throw URLError(.userAuthenticationRequired)
                }
                self.userSession = result.user
                let user = try await getUserInfo(uid: uid, token: token)
                self.currentUser = user
                await setDeviceToken()
                return (true, nil, nil)
            } catch let error as APIManager.APIError {
                switch error {
                case .serverError(let serverError):
                    if serverError.statusCode == 404 {
                        do {
                            // Delaying until account is ready
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                Task {
                                    do {
                                        guard let uid = Auth.auth().currentUser?.uid, let token = await self.getToken() else {
                                            throw URLError(.userAuthenticationRequired)
                                        }
                                        self.userSession = result.user
                                        let user = try await self.getUserInfo(uid: uid, token: token)
                                        self.currentUser = user
                                        await self.setDeviceToken()
                                    } catch {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                            Task {
                                                do {
                                                    guard let uid = Auth.auth().currentUser?.uid, let token = await self.getToken() else {
                                                        throw URLError(.userAuthenticationRequired)
                                                    }
                                                    self.userSession = result.user
                                                    let user = try await self.getUserInfo(uid: uid, token: token)
                                                    self.currentUser = user
                                                    await self.setDeviceToken()
                                                } catch {
                                                    try Auth.auth().signOut()
                                                    self.currentUser = nil
                                                    self.userSession = nil
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        return (false, "You are not signed up with Phantom Phood", 404)
                    }
                case .decodingError(let error):
                    print("DEBUG: Couldn't decode user info | Error: \(error.localizedDescription)")
                case .unknown:
                    print("DEBUG: Couldn't get user info | Error: \(error.localizedDescription)")
                }
                return (false, "Something went wrong", nil)
            }
        } catch {
            print("DEBUG: Something went wrong | Error: \(error.localizedDescription)")
            return (false, "Something went wrong", nil)
        }
    }
    
    @discardableResult
    func signinWithGoogle(tokens: GoogleSignInResult) async -> (success: Bool, error: String?, errorCode: Int?) {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        let result = await signin(credential: credential)
        return result
    }
    
    @discardableResult
    func signinWithApple(tokens: SignInWithAppleResult) async -> (success: Bool, error: String?, errorCode: Int?) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokens.token, rawNonce: tokens.nonce)
        let result = await signin(credential: credential)
        return result
    }
    
    func signup(name: String, email: String, password: String, username: String?) async throws {
        struct SignUpData: Codable {
            let userId: String
            let token: String
        }
        
        struct SignUpRequestBody: Encodable {
            let name: String
            let email: String
            let password: String
            let username: String?
        }
        
        let reqBody = try apiManager.createRequestBody(SignUpRequestBody(name: name, email: email, password: password, username: username))
        let _ = try await apiManager.requestData("/users", method: .post, body: reqBody) as SignUpData?
        
        await self.signin(email: email, password: password)
    }
    
    func signout() {
        do {
            try Auth.auth().signOut()
            
            self.currentUser = nil
            self.userSession = nil
            appData.reset()
        } catch {
            print("DEBUG: Failed to signout | Error: \(error.localizedDescription)")
        }
    }
    
    struct UserResponse: Codable {
        let success: Bool
        let data: CurrentUserFullData
    }
    func updateUserInfo() async {
        do {
            guard let uid = Auth.auth().currentUser?.uid, let token = await getToken() else { return }
            
            let data = try await apiManager.requestData("/users/\(uid)?idType=uid", method: .get, token: token) as UserResponse?
            
            if let data {
                self.currentUser = data.data
                
                await setDeviceToken()
            }
        } catch {
            print("DEBUG: Couldn't get user info | Error: \(error.localizedDescription)")
        }
    }
    func getUserInfo(uid: String, token: String) async throws -> CurrentUserFullData {
        let data = try await apiManager.requestData("/users/\(uid)?idType=uid", method: .get, token: token) as UserResponse?
        
        if let data {
            return data.data
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func requestResetPassword(email: String, _ callback: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                print("DEBUG: Unable to send reset password email | Error :\(error.localizedDescription)")
                callback(false)
            } else {
                callback(true)
            }
        }
    }
    
    func setDeviceToken() async {
        let deviceToken = UserDefaults.standard.string(forKey: "deviceToken")
        
        guard let token = await getToken(), let currentUser, let deviceToken, !deviceToken.isEmpty else {
            return
        }
        
        struct RequestBody: Encodable {
            let action = "deviceToken"
            let platform = "ios"
            let token: String
        }
        
        do {
            let body = try apiManager.createRequestBody(RequestBody(token: deviceToken))
            
            let _ = try await apiManager.requestNoContent("/users/\(currentUser.id)/settings", method: .put, body: body, token: token)
            UserDefaults.standard.removeObject(forKey: "deviceToken")
        } catch {
            print("DEBUG: Couldn't send device token | Error: \(error.localizedDescription)")
        }
    }
}
