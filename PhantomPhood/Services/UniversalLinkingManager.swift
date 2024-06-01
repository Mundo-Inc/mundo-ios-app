//
//  UniversalLinkingManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/7/24.
//

import Foundation
import StripePaymentSheet

@MainActor
final class UniversalLinkingManager {
    static let routingSchemes: [String: RouteScheme] = [
        "place": RouteScheme(pattern: ["id", "action?"], routeGetter: { components in
            var id: String?
            var action: PlaceAction?
            
            for index in components.indices {
                switch index {
                case 0:
                    id = components[index]
                case 1:
                    if components[index].lowercased() == "checkin" {
                        action = .checkin
                    } else if components[index].lowercased() == "addreview" {
                        action = .addReview
                    }
                default:
                    break
                }
            }
            
            guard let id else {
                throw LinkingError.missingParam
            }
            
            return AppRoute.place(id: id, action: action)
        }, validator: { components in
            for index in components.indices {
                switch index {
                case 0:
                    if components[index].isEmpty {
                        throw LinkingError.badParam
                    }
                default:
                    break
                }
            }
        }),
        "event": RouteScheme(pattern: ["id"], routeGetter: { components in
            var id: String?
            
            for index in components.indices {
                switch index {
                case 0:
                    id = components[index]
                default:
                    break
                }
            }
            
            guard let id else {
                throw LinkingError.missingParam
            }
            
            return AppRoute.event(.id(id))
        }, validator: { components in
            for index in components.indices {
                switch index {
                case 0:
                    if components[index].isEmpty {
                        throw LinkingError.badParam
                    }
                default:
                    break
                }
            }
        }),
        "user": RouteScheme(pattern: ["id"], routeGetter: { components in
            if let first = components.first {
                if let currentUser = Authentication.shared.currentUser, currentUser.id == first || "@\(currentUser.username)".caseInsensitiveCompare(first) == .orderedSame {
                    if !AppData.shared.navStack.isEmpty {
                        AppData.shared.navStack.removeAll()
                    }
                    AppData.shared.activeTab = .myProfile
                    // Close sheets
                    if SheetsManager.shared.presenting != nil {
                        SheetsManager.shared.presenting = nil
                    }
                } else {
                    return AppRoute.userProfile(userId: first)
                }
            }
            
            throw LinkingError.missingParam
        }, validator: { components in
            if let first = components.first {
                if first.isEmpty {
                    throw LinkingError.badParam
                }
            } else {
                throw LinkingError.missingParam
            }
        }),
        "activity": RouteScheme(pattern: ["id"], routeGetter: { components in
            if let first = components.first {
                return AppRoute.userActivity(id: first)
            }
            
            throw LinkingError.missingParam
        }, validator: { components in
            if let first = components.first {
                if first.isEmpty {
                    throw LinkingError.badParam
                }
            } else {
                throw LinkingError.missingParam
            }
        }),
        "chat": RouteScheme(pattern: ["id"], routeGetter: { components in
            if let first = components.first {
                return AppRoute.conversation(sid: first, focusOnTextField: false)
            }
            
            throw LinkingError.missingParam
        }, validator: { components in
            if let first = components.first {
                if first.isEmpty {
                    throw LinkingError.badParam
                }
            } else {
                throw LinkingError.missingParam
            }
        }),
        "inbox": RouteScheme(pattern: [], routeGetter: { _ in
            return AppRoute.inbox
        }),
        "signup": RouteScheme(pattern: ["ref?"], authRouteGetter: { components in
            if let first = components.first {
                UserDefaults.standard.setValue(first, forKey: K.UserDefaults.referredBy)
                return AuthRoute.signUpOptions
            }
            
            throw LinkingError.missingParam
        }),
    ]
    
    private let appData = AppData.shared
    private let auth = Authentication.shared
    
    private func getKeyValue(_ key: String, string: String) -> String? {
        let components = string.components(separatedBy: "/")
        for component in components {
            if component.contains("\(key)=") {
                return component.replacingOccurrences(of: "\(key)=", with: "")
            }
        }
        return nil
    }
    
    /// Handles incoming URL
    func handleIncomingURL(_ url: URL) {
        let stripeHandled = url.scheme != K.appURLScheme ? StripeAPI.handleURLCallback(with: url) : false
        
        if !stripeHandled {
            var pathComponents: [String]
            
            if url.scheme == K.appURLScheme, let newURL = URL(string: url.absoluteString.replacingOccurrences(of: "\(K.appURLScheme)://", with: "https://\(K.appDomain)/")) {
                pathComponents = newURL.pathComponents
            } else {
                pathComponents = url.pathComponents
            }
            
            if let first = pathComponents.first, first == "/" {
                pathComponents.removeFirst()
            }
            
            guard
                let startScheme = pathComponents.first,
                let item = UniversalLinkingManager.routingSchemes[startScheme]
            else { return }
            
            pathComponents.removeFirst()
            
            do {
                try item.validate(pathComponents)
            } catch {
                return
            }
            
            switch item.router {
            case .app:
                guard let route = try? item.getRoute(pathComponents) else { return }
                /// return if not signed in
                guard auth.userSession != nil else { return }
                appData.goTo(route)
                
                // Close sheets
                if SheetsManager.shared.presenting != nil {
                    SheetsManager.shared.presenting = nil
                }
            case .auth:
                guard let route = try? item.getAuthRoute(pathComponents), auth.userSession == nil else { return }
                if appData.authNavStack.isEmpty {
                    appData.authNavStack.append(route)
                    
                    // Close sheets
                    if SheetsManager.shared.presenting != nil {
                        SheetsManager.shared.presenting = nil
                    }
                }
            }
        }
    }
}
