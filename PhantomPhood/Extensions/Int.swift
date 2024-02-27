//
//  Int.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/23/24.
//

import Foundation

extension Int {
    func formattedWithSuffix() -> String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1_000_000
        let billion = number / 1_000_000_000
        
        func format(_ value: Double) -> String {
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(value))"
            } else {
                return String(format: "%.1f", floor(value * 10) / 10)
            }
        }
        
        if billion >= 1 {
            return format(billion) + "B"
        } else if million >= 1 {
            return format(million) + "M"
        } else if thousand >= 1 {
            return format(thousand) + "k"
        } else {
            return self.formatted()
        }
    }
}
