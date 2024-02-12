//
//  UniversalLinkingManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/7/24.
//

import Foundation

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
        "user": RouteScheme(pattern: ["id"], routeGetter: { components in
            if let first = components.first {
                return AppRoute.userProfile(userId: first)
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
        "signup": RouteScheme(pattern: ["ref?"], authRouteGetter: { components in
            if let first = components.first {
                // TODO: Pass in the optional ref
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
    /// - Note: e.g. `phantom://tab=home/nav=place/id=645c1d1ab41f8e12a0d166bc`
    func handleIncomingURL(_ url: URL) {
        var pathComponents = url.pathComponents
        
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
        case .auth:
            guard let route = try? item.getAuthRoute(pathComponents), auth.userSession == nil else { return }
            appData.authNavStack.append(route)
        }
    }
}
