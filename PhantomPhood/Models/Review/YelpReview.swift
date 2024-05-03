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
        let name: String
        let profileUrl: URL?
        let imageUrl: URL?
        
        enum CodingKeys: String, CodingKey {
            case id, profileUrl, imageUrl, name
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            profileUrl = try container.decodeURLIfPresent(forKey: .profileUrl)
            imageUrl = try container.decodeURLIfPresent(forKey: .imageUrl)
        }
    }
    
    let id: String
    let url: String
    let text: String
    let rating: Int
    let timeCreated: String
    let user: YelpUser
}
