//
//  DateFormatter.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 22.09.2023.
//

import Foundation

extension DateFormatter {
    static func getPassedTime(from: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let date = formatter.date(from: "2022-01-05T03:30:00.000Z")
        if let date {
            return date.description
        } else {
            return "Unknown"
        }
    }
}
