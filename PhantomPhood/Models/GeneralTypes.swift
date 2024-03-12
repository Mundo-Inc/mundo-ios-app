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

struct APIResponseWithPagination<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let pagination: Pagination
    
    struct Pagination: Decodable {
        let totalCount: Int
        let page: Int
        let limit: Int
    }
}

enum IdOrData<T: Identifiable>: Hashable {
    static func ==(lhs: IdOrData<T>, rhs: IdOrData<T>) -> Bool {
        switch (lhs, rhs) {
        case let (.id(id1), .id(id2)):
            return id1 == id2
        case let (.data(data1), .data(data2)):
            return data1.id == data2.id
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .id(let string):
            hasher.combine(string)
        case .data(let t):
            hasher.combine(t.id)
        }
    }
    
    case id(String)
    case data(T)
}
