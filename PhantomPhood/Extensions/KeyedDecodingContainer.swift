//
//  KeyedDecodingContainer.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/3/24.
//

import Foundation

extension KeyedDecodingContainer {
    /// Decodes a URL from a string associated with the given key.
    ///
    /// If the string is empty or not present, returns `nil`.
    ///
    /// - Parameter key: Key to decode the URL from.
    /// - Returns: URL or `nil`.
    /// - Throws: Decoding error on failure.
    func decodeURLIfPresent(forKey key: Key) throws -> URL? {
        if let urlString = try decodeIfPresent(String.self, forKey: key), !urlString.isEmpty {
            return URL(string: urlString)
        }
        return nil
    }
    
    /// Decodes a URL array from an array of strings associated with the given key.
    ///
    /// If the string is empty or not present, returns `[]`.
    ///
    /// - Parameter key: Key to decode the URL from.
    /// - Returns: `[URL]`
    /// - Throws: Decoding error on failure.
    func decodeURLArrayIfPresent(forKey key: Key) throws -> [URL] {
        if let stringArray = try decodeIfPresent([String].self, forKey: key) {
            return stringArray.compactMap { $0.isEmpty ? nil : URL(string: $0) }
        }
        return []
    }
    
    /// Decodes an optional string associated with the given key.
    ///
    /// Treats empty strings as `nil`.
    ///
    /// - Parameter key: Key to decode the string from.
    /// - Returns: String or `nil`.
    /// - Throws: Decoding error on failure.
    func decodeOptionalString(forKey key: Key) throws -> String? {
        if let stringValue = try decodeIfPresent(String.self, forKey: key), !stringValue.isEmpty {
            return stringValue
        }
        return nil
    }
}
