//
//  Date.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/22/24.
//

import Foundation

extension Date {
    /// Returns remaining time until the date in format "HH:mm:ss"
    /// - Returns: Remaining time in format "HH:mm:ss"
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
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
