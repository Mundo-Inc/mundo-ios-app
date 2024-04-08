//
//  MediaItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/26/24.
//

import Foundation

enum MediaType: String, Decodable {
    case image = "image"
    case video = "video"
}
struct MediaItem: Identifiable, Decodable {
    let id: String
    let src: URL?
    let caption: String?
    let type: MediaType
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case src, caption, type
    }
    
    var thumbnail: URL? {
        switch self.type {
        case .image:
            return nil
        case .video:
            if let src, let url = URL(string: src.absoluteString.replacingOccurrences(of: ".mp4", with: "-thumbnail.jpg")) {
                return url
            }
            return nil
        }
    }
}

struct MediaWithUser: Identifiable, Decodable {
    let id: String
    let src: URL?
    let caption: String?
    let type: MediaType
    let user: UserEssentials?
    // TODO: When we remove third party media we can change this to not-optional
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case src, caption, type, user
    }
    
    var thumbnail: URL? {
        switch self.type {
        case .image:
            return nil
        case .video:
            if let src, let url = URL(string: src.absoluteString.replacingOccurrences(of: ".mp4", with: "-thumbnail.jpg")) {
                return url
            }
            return nil
        }
    }
}

enum MixedMedia {
    case phantom(MediaWithUser)
    case yelp(String)
}
