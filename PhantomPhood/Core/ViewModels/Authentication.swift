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

struct CurrentUserFullData: Codable {
    let id: String
    let name: String
    let username: String
    let profileImage: URL?
    var bio: String?
    let email: Email
    let phone: Phone?
    let rank, remainingXp, prevLevelXp, reviewsCount, followersCount, followingCount, totalCheckins: Int
    let role: UserRole
    let verified: Bool
    let isPrivate: Bool
    let progress: UserProgress
    let acceptedEula: Date?
    
    struct Email: Codable {
        let address: String
        let verified: Bool
    }
    
    struct Phone: Codable {
        let number: String?
        let verified: Bool?
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, profileImage, bio, email, phone, rank, remainingXp, prevLevelXp, reviewsCount, followersCount, followingCount, totalCheckins, role, verified, isPrivate, progress, acceptedEula
    }
    
    var levelProgress: Double {
        Double(self.progress.xp - self.prevLevelXp) / Double(self.progress.xp + self.remainingXp - self.prevLevelXp)
    }
}

extension CurrentUserFullData {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        bio = try container.decodeOptionalString(forKey: .bio)
        email = try container.decode(Email.self, forKey: .email)
        phone = try container.decodeIfPresent(Phone.self, forKey: .phone)
        rank = try container.decode(Int.self, forKey: .rank)
        remainingXp = try container.decode(Int.self, forKey: .remainingXp)
        prevLevelXp = try container.decode(Int.self, forKey: .prevLevelXp)
        reviewsCount = try container.decode(Int.self, forKey: .reviewsCount)
        followersCount = try container.decode(Int.self, forKey: .followersCount)
        followingCount = try container.decode(Int.self, forKey: .followingCount)
        totalCheckins = try container.decode(Int.self, forKey: .totalCheckins)
        role = try container.decode(UserRole.self, forKey: .role)
        verified = try container.decode(Bool.self, forKey: .verified)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        progress = try container.decode(UserProgress.self, forKey: .progress)
        acceptedEula = try container.decodeIfPresent(Date.self, forKey: .acceptedEula)
        profileImage = try container.decodeURLIfPresent(forKey: .profileImage)
    }
}

final class Authentication: ObservableObject {
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
            DispatchQueue.main.async {
                self?.userSession = user
                if user == nil {
                    self?.currentUser = nil
                }
            }
        }
        
        Task {
            await updateUserInfo()
        }
    }
    
    // MARK: - Public Methods
    
    func getToken() async throws -> String {
        guard let token = try? await Auth.auth().currentUser?.getIDToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        return token
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                self.userSession = result.user
            }
            do {
                guard let uid = Auth.auth().currentUser?.uid else {
                    throw URLError(.userAuthenticationRequired)
                }
                
                let token = try await getToken()
                
                let user = try await getUserInfo(uid: uid, token: token)
                await MainActor.run {
                    self.currentUser = user
                }
                await setDeviceToken()
            } catch {
                throw AuthenticationError.failedToGetUserInfo
            }
        } catch {
            throw AuthenticationError.incorrectCredentials
        }
    }
    
    func signIn(credential: AuthCredential) async throws {
        let result = try await Auth.auth().signIn(with: credential)
        
        do {
            guard let uid = Auth.auth().currentUser?.uid else {
                throw URLError(.userAuthenticationRequired)
            }
            
            let token = try await getToken()
            
            await MainActor.run {
                self.userSession = result.user
            }
            let user = try await getUserInfo(uid: uid, token: token)
            await MainActor.run {
                self.currentUser = user
            }
            await setDeviceToken()
        } catch let error as APIManager.APIError {
            if case .serverError(let serverError) = error, serverError.statusCode == 404 {
                // Delaying until account is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    Task {
                        do {
                            guard let uid = Auth.auth().currentUser?.uid else {
                                throw URLError(.userAuthenticationRequired)
                            }
                            let token = try await self.getToken()
                            
                            await MainActor.run {
                                self.userSession = result.user
                            }
                            let user = try await self.getUserInfo(uid: uid, token: token)
                            await MainActor.run {
                                self.currentUser = user
                            }
                            await self.setDeviceToken()
                        } catch {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                Task {
                                    do {
                                        guard let uid = Auth.auth().currentUser?.uid else {
                                            throw URLError(.userAuthenticationRequired)
                                        }
                                        let token = try await self.getToken()
                                        
                                        await MainActor.run {
                                            self.userSession = result.user
                                        }
                                        let user = try await self.getUserInfo(uid: uid, token: token)
                                        await MainActor.run {
                                            self.currentUser = user
                                        }
                                        await self.setDeviceToken()
                                    } catch {
                                        try Auth.auth().signOut()
                                        await MainActor.run {
                                            self.currentUser = nil
                                            self.userSession = nil
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                throw AuthenticationError.notSignedUpWithUs
            }
            
            throw error
        }
    }
    
    func signinWithGoogle(tokens: GoogleSignInResult) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        try await signIn(credential: credential)
    }
    
    func signinWithApple(tokens: SignInWithAppleResult) async throws {
        let credential = OAuthProvider.appleCredential(withIDToken: tokens.token, rawNonce: tokens.nonce, fullName: tokens.fullName)
        try await signIn(credential: credential)
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
        
        try? await self.signIn(email: email, password: password)
    }
    
    func signOut() async {
        do {
            try Auth.auth().signOut()
            
            do {
                try DataStack.shared.deleteAll()
            } catch {
                presentErrorToast(error, silent: true)
            }
            
            UserSettings.shared.logoutCleanup()
            
            await MainActor.run {
                currentUser = nil
                appData.reset()
            }
        } catch {
            print("DEBUG: Failed to sign out | Error: \(error.localizedDescription)")
        }
    }
    
    func updateUserInfo() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let token = try await getToken()
            
            let data: APIResponse<CurrentUserFullData> = try await apiManager.requestData("/users/\(uid)?idType=uid", method: .get, token: token)
            
            await MainActor.run {
                self.currentUser = data.data
            }
            
            UserSettings.shared.setUserInfo(data.data)
            
            await setDeviceToken()
        } catch {
            print("DEBUG: Couldn't get user info | Error: \(error)")
        }
    }
    func getUserInfo(uid: String, token: String) async throws -> CurrentUserFullData {
        let data: APIResponse<CurrentUserFullData> = try await apiManager.requestData("/users/\(uid)?idType=uid", method: .get, token: token)
        
        UserSettings.shared.setUserInfo(data.data)
        return data.data
    }
    
    func requestResetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func setDeviceToken() async {
        let apnToken = UserDefaults.standard.string(forKey: K.UserDefaults.apnToken)
        let fcmToken = UserDefaults.standard.string(forKey: K.UserDefaults.fcmToken)
        
        guard let token = try? await getToken(), let currentUser, let apnToken, !apnToken.isEmpty, let fcmToken, !fcmToken.isEmpty else {
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
            
            UserDefaults.standard.removeObject(forKey: K.UserDefaults.apnToken)
            UserDefaults.standard.removeObject(forKey: K.UserDefaults.fcmToken)
        } catch {
            presentErrorToast(error, debug: "Couldn't send device token", silent: true)
        }
    }
}

extension Authentication {
    enum AuthenticationError: LocalizedError {
        case failedToGetUserInfo
        case incorrectCredentials
        case notSignedUpWithUs
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .failedToGetUserInfo:
                "Couldn't get user info"
            case .incorrectCredentials:
                "Email/Password is incorrect"
            case .notSignedUpWithUs:
                "You are not signed up with \(K.appName)"
            case .unknown:
                "Something went wrong"
            }
        }
    }
}
