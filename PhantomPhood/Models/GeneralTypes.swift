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

struct PaginatedAPIResponse<T: Decodable>: Decodable {
    let success: Bool
    let total: Int
    let data: T
}

struct APIResponseWithPagination<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let pagination: Pagination
    
    struct Pagination: Decodable {
        let total: Int
        let page: Int
        let limit: Int
    }
}
