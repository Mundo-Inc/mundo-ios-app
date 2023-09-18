//
//  NavigationModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12.09.2023.
//

import Foundation

enum AppScreens {
    case feed
}



struct NavigationModel: Hashable {
    let screen: AppScreens
    let params: [String: String]? = nil
}

struct AuthNavigationModel: Hashable {
    let screen: AuthScreens
    let params: [String: String]? = nil
}
