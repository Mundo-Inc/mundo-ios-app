//
//  Date.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/22/24.
//

import Foundation

extension Date {
    enum TimeElapsedFormat {
        case full
        case compact
    }
    
    /// Returns remaining time until the date in format "HH:mm:ss" or "DD" if the date is more than 24 hours away
    /// - Returns: Remaining time in format "HH:mm:ss" or "DD"
    /// - Note: If the date is in the past, returns nil
    func remainingTime() -> String? {
        let now = Date()
        if now > self {
            return nil
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: now, to: self)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        if hours >= 24 {
            let days = hours / 24
            return String(format: "%d day%@", days, days == 1 ? "" : "s")
        }
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func timeElapsed(format: TimeElapsedFormat = .compact, suffix: String = "") -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: now)
        
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
            return "now"
        }
    }
    
    // Returns the time component of the Date in "HH:mm" format (24-hour format).
    /// - Returns: A string representing the formatted time.
    func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current // Ensure the time zone is set correctly
        dateFormatter.dateFormat = "HH:mm" // Use "hh:mm a" for 12-hour format with AM/PM
        return dateFormatter.string(from: self)
    }
}

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}
