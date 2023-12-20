//
//  DateFormatter.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 22.09.2023.
//

import Foundation

extension DateFormatter {
    enum TimeElapsedFormat {
        case full
        case compact
    }
    
    static func getPassedTime(from dateString: String, format: TimeElapsedFormat = .compact, suffix: String = "") -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let date = formatter.date(from: dateString)
        
        
        if let date {
            return self.timeElapsed(from: date, format: format, suffix: suffix)
        } else {
            return "Unknown"
        }
    }

    static func timeElapsed(from date: Date, format: TimeElapsedFormat = .compact, suffix: String = "") -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years)\(format == .full ? " year\(years > 1 ? "s" : "")" : "y")\(suffix)"
        } else if let months = components.month, months > 0 {
            return "\(months)\(format == .full ? " month\(months > 1 ? "s" : "")" : "mo")\(suffix)"
        } else if let days = components.day, days > 0 {
            return "\(days)\(format == .full ? " day\(days > 1 ? "s" : "")" : "d")\(suffix)"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)\(format == .full ? " hour\(hours > 1 ? "s" : "")" : "h")\(suffix)"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)\(format == .full ? " minute\(minutes > 1 ? "s" : "")" : "m")\(suffix)"
        } else {
            return "just now"
        }
    }
    
    static func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.string(from: date)
    }

    static func dateToShortString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: date)
    }

    static func stringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return dateFormatter.date(from: dateString)
    }
}
