//
//  Checkin.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import Foundation

struct Checkin: Identifiable, Decodable {
    let _id: String
    let createdAt: String
    let user: User
    let place: BriefPlace
    
    var id: String {
        self._id
    }
}
