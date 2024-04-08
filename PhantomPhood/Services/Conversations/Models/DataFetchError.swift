//
//  DataFetchError.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/4/24.
//

import Foundation

public enum DataFetchError: Error {
    case requiredDataCallsFailed
    case conversationsClientIsNotAvailable
    case dataIsInconsistent
}
