//
//  GoogleReview.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/6/24.
//

import Foundation

struct GoogleReview: Decodable {
    let name: String
    let text: LocalizedText?
    let originalText: LocalizedText?
    let rating: Double
    let authorAttribution: AuthorAttribution
    let publishTime: String
    let relativePublishTimeDescription: String
    
    struct LocalizedText: Decodable {
        let text: String
        let languageCode: String
    }
    
    struct AuthorAttribution: Decodable {
        let displayName: String
        let uri: URL
        let photoUri: URL
    }
}
