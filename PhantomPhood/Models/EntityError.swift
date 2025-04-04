//
//  EntityError.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/28/24.
//

import Foundation

enum EntityError: Error, LocalizedError {
    case missingStructRequiredData
    case notFound
    
    var errorDescription: String {
        switch self {
        case .missingStructRequiredData:
            "Missing required data for creating struct from entity"
        case .notFound:
            "Entity does not exist on CoreData"
        }
    }
}
