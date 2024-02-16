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
import FirebaseCore

enum UserRole: String, Codable {
    case user
    case admin
}

struct CurrentUserCoreData: Codable, Identifiable {
    let id, name, username, profileImage: String
    let bio: String?
    let email: Email
    let role: UserRole
    let verified: Bool
    let progress: UserProgress
    
    struct Email: Codable {
        let address: String
        let verified: Bool
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, profileImage, bio, email, role, verified, progress
    }
}

struct CurrentUserFullData: Codable {
    let id, name, username, profileImage: String
    var bio: String?
    let email: Email
    let rank, remainingXp, reviewsCount, followersCount, followingCount, totalCheckins: Int
    let role: UserRole
    let verified: Bool
    let progress: UserProgress
    let accepted_eula: Date?
    
    struct Email: Codable {
        let address: String
        let verified: Bool
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, profileImage, bio, email, rank, remainingXp, reviewsCount, followersCount, followingCount, totalCheckins, role, verified, progress, accepted_eula
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
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            self?.userSession = user
        }

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
    func signIn(email: String, password: String) async -> (success: Bool, error: String?, errorCode: Int?) {
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
    func signIn(credential: AuthCredential) async -> (success: Bool, error: String?, errorCode: Int?) {
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
        let result = await signIn(credential: credential)
        return result
    }
    
    @discardableResult
    func signinWithApple(tokens: SignInWithAppleResult) async -> (success: Bool, error: String?, errorCode: Int?) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokens.token, rawNonce: tokens.nonce)
        let result = await signIn(credential: credential)
        return result
    }
    
    func signUp(name: String, email: String, password: String, username: String?, referrer: String?) async throws {
        struct SignUpRequestBody: Encodable {
            let name: String
            let email: String
            let password: String
            let username: String?
            let referrer: String?
        }
        
        let reqBody = try apiManager.createRequestBody(SignUpRequestBody(name: name, email: email, password: password, username: username, referrer: referrer))
        try await apiManager.requestNoContent("/users", method: .post, body: reqBody)
        
        await self.signIn(email: email, password: password)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            self.currentUser = nil
            self.userSession = nil
            
            UserSettings.shared.logoutCleanup()
            appData.reset()
        } catch {
            print("DEBUG: Failed to sign out | Error: \(error.localizedDescription)")
        }
    }
    
    func updateUserInfo() async {
        do {
            guard let uid = Auth.auth().currentUser?.uid, let token = await getToken() else { return }
            
            let data = try await apiManager.requestData("/users/\(uid)?idType=uid", method: .get, token: token) as APIResponse<CurrentUserFullData>?
            
            if let data {
                self.currentUser = data.data
                
                UserSettings.shared.setUserInfo(data.data)
                
                await setDeviceToken()
            }
        } catch {
            print(error)
            print("DEBUG: Couldn't get user info | Error: \(error.localizedDescription)")
        }
    }
    func getUserInfo(uid: String, token: String) async throws -> CurrentUserFullData {
        let data = try await apiManager.requestData("/users/\(uid)?idType=uid", method: .get, token: token) as APIResponse<CurrentUserFullData>?
        
        if let data {
            UserSettings.shared.setUserInfo(data.data)
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
        let apnToken = UserDefaults.standard.string(forKey: "apnToken")
        let fcmToken = UserDefaults.standard.string(forKey: "fcmToken")
        
        guard let token = await getToken(), let currentUser, let apnToken, !apnToken.isEmpty, let fcmToken, !fcmToken.isEmpty else {
            return
        }
        
        struct RequestBody: Encodable {
            let action = "deviceToken"
            let platform = "ios"
            let apnToken: String
            let fcmToken: String
        }
        
        do {
            let body = try apiManager.createRequestBody(RequestBody(apnToken: apnToken, fcmToken: fcmToken))
            
            try await apiManager.requestNoContent("/users/\(currentUser.id)/settings", method: .put, body: body, token: token)
            
            UserDefaults.standard.removeObject(forKey: "apnToken")
            UserDefaults.standard.removeObject(forKey: "fcmToken")
        } catch {
            print("DEBUG: Couldn't send device token | Error: \(error.localizedDescription)")
        }
    }
}
