//
//  GeneralTypes.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/2/23.
//

import Foundation

enum RefreshNewAction {
    case refresh
    case new
}

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}