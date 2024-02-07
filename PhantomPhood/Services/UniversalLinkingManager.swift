//
//  UniversalLinkingManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/7/24.
//

import Foundation

@MainActor
final class UniversalLinkingManager {
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
    
    func handleIncomingURL(_ url: URL) {
        // return if not signed in
        guard auth.userSession != nil, let scheme = url.scheme else { return }
        
        if scheme == "phantom" {
            // phantom://tab=home/nav=place/id=645c1d1ab41f8e12a0d166bc
            let string = url.absoluteString.replacingOccurrences(of: "phantom://", with: "")
            let components = string.components(separatedBy: "/")
            
            var tabSet = false
            for component in components {
                if component.contains("tab=") {
                    let tabRawValue = component.replacingOccurrences(of: "tab=", with: "")
                    if let requestedTab = Tab.convert(from: tabRawValue) {
                        appData.activeTab = requestedTab
                        tabSet = true
                    }
                } else if !tabSet {
                    // return if tab is not specified
                    return
                }
                if component.contains("nav") {
                    let navRawValue = component.replacingOccurrences(of: "nav=", with: "").lowercased()
                    switch navRawValue {
                    case "notifications":
                        appData.goTo(.notifications)
                    case "user":
                        if let id = getKeyValue("id", string: string) {
                            appData.goTo(.userProfile(userId: id.lowercased()))
                        }
                    case "place":
                        if let id = getKeyValue("id", string: string) {
                            appData.goTo(.place(id: id.lowercased()))
                        }
                    case "settings":
                        appData.goTo(.settings)
                    case "myConnections":
                        if let tab = getKeyValue("tab", string: string)?.lowercased(), (tab == "followers" || tab == "followings") {
                            appData.goTo(.myConnections(initTab: tab == "followers" ? .followers : .followings))
                        }
                    default:
                        break
                    }
                }
            }
        } else if scheme == "https" {
            // https://phantomphood.ai/place/6561679c15727151d1a5355f
            let string = url.absoluteString.replacingOccurrences(of: "https://phantomphood.ai/", with: "")
            let components = string.components(separatedBy: "/")
            
            guard let type = components.first, components.endIndex >= 1 else { return }
            
            let id = components[1]
            
            switch type {
            case "place":
                appData.goTo(AppRoute.place(id: id))
            case "user":
                appData.goTo(AppRoute.userProfile(userId: id))
            case "activity":
                appData.goTo(AppRoute.userActivity(id: id))
            default:
                break
            }
        }
    }
}
