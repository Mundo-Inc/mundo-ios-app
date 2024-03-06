//
//  YelpReview.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/6/24.
//

import Foundation

struct YelpReview: Identifiable, Decodable {
    struct YelpUser: Identifiable, Decodable {
        let id: String
        let profileUrl: String
        let imageUrl: String?
        let name: String
    }
    
    let id: String
    let url: String
    let text: String
    let rating: Int
    let timeCreated: String
    let user: YelpUser
}
