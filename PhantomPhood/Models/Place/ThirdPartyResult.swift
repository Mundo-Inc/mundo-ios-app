//
//  ThirdPartyResult.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/14/24.
//

import Foundation

struct ThirdPartyResult: Decodable {
    let google: GoogleResult?
    let yelp: YelpResult?
    
    struct GoogleResult: Decodable {
        let rating: Double
        let reviewCount: Int
        let thumbnail: URL?
        let openingHours: OpenningHours?
        
        struct OpenningHours: Decodable {
            let openNow: Bool
            let periods: [Periods]
            let weekdayDescriptions: [String]
            
            struct Periods: Decodable {
                let open: DayTime
                let close: DayTime
                
                struct DayTime: Decodable {
                    let day: Int
                    let hour: Int
                    let minute: Int
                }
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case rating, reviewCount, thumbnail, openingHours
        }
        
        init(rating: Double, reviewCount: Int, thumbnail: URL?, openingHours: OpenningHours?) {
            self.rating = rating
            self.reviewCount = reviewCount
            self.thumbnail = thumbnail
            self.openingHours = openingHours
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            rating = try container.decode(Double.self, forKey: .rating)
            reviewCount = try container.decode(Int.self, forKey: .reviewCount)
            thumbnail = try container.decodeURLIfPresent(forKey: .thumbnail)
            openingHours = try container.decodeIfPresent(OpenningHours.self, forKey: .openingHours)
        }
    }
    
    struct YelpResult: Decodable, Identifiable {
        let id: String
        let reviewCount: Int
        let rating: Double
        let phone: String
        let photos: [MediaItem]
        let url: URL?
        let thumbnail: URL?
        let categories: [Category]?
        let transactions: [String]?
        let price: String?
        
        /// Yelp Category
        struct Category: Decodable {
            let title: String
            let alias: String
        }
        
        enum CodingKeys: String, CodingKey {
            case id, reviewCount, rating, phone, photos, url, thumbnail, categories, transactions, price
        }
        
        init(id: String, reviewCount: Int, rating: Double, phone: String, photos: [MediaItem], url: URL?, thumbnail: URL?, categories: [Category]?, transactions: [String]?, price: String?) {
            self.id = id
            self.reviewCount = reviewCount
            self.rating = rating
            self.phone = phone
            self.photos = photos
            self.url = url
            self.thumbnail = thumbnail
            self.categories = categories
            self.transactions = transactions
            self.price = price
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            reviewCount = try container.decode(Int.self, forKey: .reviewCount)
            rating = try container.decode(Double.self, forKey: .rating)
            phone = try container.decode(String.self, forKey: .phone)
            photos = try container.decodeURLArrayIfPresent(forKey: .photos).map({ .init(id: UUID().uuidString, type: .image, src: $0, source: .yelp) })
            url = try container.decodeURLIfPresent(forKey: .url)
            thumbnail = try container.decodeURLIfPresent(forKey: .thumbnail)
            categories = try container.decodeIfPresent([Category].self, forKey: .categories)
            transactions = try container.decodeIfPresent([String].self, forKey: .transactions)
            price = try container.decodeIfPresent(String.self, forKey: .price)
        }
    }
}
