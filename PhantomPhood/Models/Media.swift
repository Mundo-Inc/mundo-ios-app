//
//  Media.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

enum MediaType: String, Decodable {
    case image = "image"
    case video = "video"
}
struct Media: Identifiable, Decodable {
    let id: String
    let src: String
    let caption: String?
    let type: MediaType
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case src, caption, type
    }
}

struct MediaWithUser: Identifiable, Decodable {
    let id: String
    let src: String
    let caption: String?
    let type: MediaType
    let user: UserEssentials?
    // TODO: When we remove third party media we can change this to not-optional
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case src, caption, type, user
    }
}
