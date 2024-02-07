//
//  Date.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/22/24.
//

import Foundation

extension Date {
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
}
