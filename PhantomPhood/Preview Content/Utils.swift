//
//  Utils.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 21.09.2023.
//

import Foundation

func decodeFeedItem(from jsonString: String) -> FeedItem? {
    let data = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()

    do {
        let feedItem = try decoder.decode(FeedItem.self, from: data)
        return feedItem
    } catch {
        print("Error decoding FeedItem: \(error)")
        return nil
    }
}
