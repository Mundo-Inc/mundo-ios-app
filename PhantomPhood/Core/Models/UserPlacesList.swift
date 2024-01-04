//
//  UserPlacesList.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/29/23.
//

import Foundation

struct UserPlacesList: Identifiable, Decodable {
    let _id: String
    let name: String
    let owner: CompactUser
    let icon: String
    let collaborators: [ListCollaborator]
    let placesCount: Int
    let isPrivate: Bool
    let createdAt: String
    let places: [ListPlace]
    
    var id: String {
        self._id
    }
    
    struct ListPlace: Identifiable, Decodable {
        let place: BriefPlace
        let user: CompactUser
        let createdAt: String
        
        var id: String {
            self.place.id
        }
    }
}

struct CompactUserPlacesList: Identifiable, Decodable {
    let _id: String
    let name: String
    let owner: CompactUser
    let icon: String
    let collaboratorsCount: Int
    let placesCount: Int
    let isPrivate: Bool
    let createdAt: String
    
    var id: String {
        self._id
    }
}

enum ListCollaboratorAccess: String, Decodable {
    case edit = "edit"
    case view = "view"
}

struct ListCollaborator: Identifiable, Decodable {
    let user: CompactUser
    let access: ListCollaboratorAccess
    
    var id: String {
        self.user.id
    }
}
