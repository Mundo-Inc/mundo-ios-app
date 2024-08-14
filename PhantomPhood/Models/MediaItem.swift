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
    let type: MediaType
    let src: URL?
    let caption: String?
    let user: UserEssentials?
    let source: MediaSource
    
    init(id: String, type: MediaType, src: URL?, caption: String?, user: UserEssentials?) {
        self.id = id
        self.type = type
        self.src = src
        self.caption = caption
        self.user = user
        self.source = .mundo
    }
    
    init(id: String, type: MediaType, src: URL?, source: MediaSource) {
        self.id = id
        self.src = src
        self.type = type
        self.source = source
        self.user = nil
        self.caption = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(MediaType.self, forKey: .type)
        src = try container.decodeURLIfPresent(forKey: .src)
        caption = try container.decodeOptionalString(forKey: .caption)
        user = try container.decodeIfPresent(UserEssentials.self, forKey: .user)
        source = .mundo
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
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type, src, caption, user
    }
    
    enum MediaSource {
        case mundo
        case google
        case yelp
    }
}
