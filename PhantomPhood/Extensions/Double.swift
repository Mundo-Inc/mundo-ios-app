//
//  Double.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/27/24.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value.
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func asCurrency(asCent: Bool = true) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en-US")
        
        return formatter.string(from: (asCent ? self / 100 : self) as NSNumber)
    }
}
