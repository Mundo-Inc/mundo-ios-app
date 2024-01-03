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
    let collaborators: [CompactUser]
    let placesCount: Int
    let isPrivate: Bool
    let createdAt: String
    
    var id: String {
        self._id
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
