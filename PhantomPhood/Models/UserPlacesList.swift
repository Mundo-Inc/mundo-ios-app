//
//  UserPlacesList.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/29/23.
//

import Foundation

struct UserPlacesList: Identifiable, Decodable {
    let id: String
    let name: String
    let owner: UserEssentials
    let icon: String
    let collaborators: [ListCollaborator]
    let placesCount: Int
    let isPrivate: Bool
    let createdAt: String
    let places: [ListPlace]
    
    struct ListPlace: Identifiable, Decodable {
        let place: PlaceEssentials
        let user: UserEssentials
        let createdAt: String
        
        var id: String {
            self.place.id
        }
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, owner, icon, collaborators, placesCount, isPrivate, createdAt, places
    }
}

struct CompactUserPlacesList: Identifiable, Decodable {
    let id: String
    let name: String
    let owner: UserEssentials
    let icon: String
    let collaboratorsCount: Int
    let placesCount: Int
    let isPrivate: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, owner, icon, collaboratorsCount, placesCount, isPrivate, createdAt
    }
}

struct ListCollaborator: Identifiable, Decodable {
    let user: UserEssentials
    let access: Access
    
    var id: String {
        self.user.id
    }
    
    enum Access: String, Decodable {
        case edit = "edit"
        case view = "view"
    }
}
