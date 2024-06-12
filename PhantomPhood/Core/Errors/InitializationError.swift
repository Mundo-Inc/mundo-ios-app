//
//  InitializationError.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 6/12/24.
//

import Foundation

/// An enumeration representing errors that can occur during the initialization of objects
enum InitializationError: LocalizedError {
    /// Indicates that the array provided for initialization is empty.
    case emptyArray(description: String)
    
    var errorDescription: String {
        return switch self {
        case .emptyArray(let description):
            "Initialization failed: \(description)"
        }
    }
    
    var failureReason: String {
        return switch self {
        case .emptyArray:
            "The provided array is empty. Ensure that the array contains at least one item."
        }
    }
}
