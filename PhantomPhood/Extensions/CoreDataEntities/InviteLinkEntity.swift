//
//  InviteLinkEntity.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/16/24.
//

import Foundation

extension InviteLinkEntity {
    var expiresAt: Date {
        if let createdAt {
            // 30 days
            return createdAt.addingTimeInterval(60 * 60 * 24 * 30)
        } else {
            return .distantFuture
        }
    }
}
