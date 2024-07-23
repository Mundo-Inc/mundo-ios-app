//
//  AppGeneralVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/29/23.
//

import Foundation

@MainActor
class AppGeneralVM: ObservableObject {
    static let shared = AppGeneralVM()
    private init() {}
    
    private let apiManager = APIManager.shared
    private let auth = Authentication.shared
    
    @Published var showForceUpdate = false
    @Published var appInfo: AppInfoResponse?
    @Published var appVersion: String = ""
    
    struct AppInfoResponse: Decodable {
        let isLatest: Bool
        let latestAppVersion: String
        let isOperational: Bool
        let minOperationalVersion: String
        let message: String
    }
    
    func checkVersion() async {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        do {
            if let appVersion {
                self.appVersion = appVersion
                
                let token = await auth.getToken()
                
                let data: APIResponse<AppInfoResponse> = try await apiManager.requestData("/general/app-version/\(appVersion)", token: token)
                
                self.appInfo = data.data
                
                if !data.data.isOperational {
                    self.showForceUpdate = true
                } else {
                    if self.showForceUpdate {
                        self.showForceUpdate = false
                    }
                }
            }
        } catch {
            presentErrorToast(error, debug: "Failed to get version information", silent: true)
        }
    }
}
