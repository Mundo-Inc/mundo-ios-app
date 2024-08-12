//
//  Country.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 8/6/24.
//

import Foundation

struct Country: Hashable, Identifiable, Decodable {
    /// Country Code
    let id: String
    let name: String
    let emoji: String
    let image: URL
    let slug: String
    let dialCode: String
    
    enum CodingKeys: String, CodingKey {
        case name, code, emoji, image, slug, dialCodes
    }
    
    public static let US: Country = Country(
        id: "US",
        name: "United States",
        emoji: "🇺🇸",
        image: URL(string: "https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.2.3/flags/4x3/us.svg")!,
        slug: "united-states",
        dialCode: "+1"
    )
    
    public static let list: [Country] = {
        getList() ?? []
    }()
    
    public static let sortedByDialCodeList = Self.list.sorted { $0.dialCode.count > $1.dialCode.count }
    
    public static func find(dialCode: String) -> Country? {
        Self.sortedByDialCodeList.first { $0.dialCode == dialCode }
    }
    
    public static func find(phoneNumber: String) -> Country? {
        for country in Self.sortedByDialCodeList {
            if phoneNumber.hasPrefix(country.dialCode) {
                return country
            }
        }
        
        return nil
    }
    
    private static func getList() -> [Country]? {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let countries = try JSONDecoder().decode([Country].self, from: data)
            return countries
        } catch {
            return nil
        }
    }
}


extension Country {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .code)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)
        image = try container.decodeURLIfPresent(forKey: .image)!
        slug = try container.decode(String.self, forKey: .slug)
        let dialCodes = try container.decode([String].self, forKey: .dialCodes)
        dialCode = dialCodes.first ?? "--"
    }
}
