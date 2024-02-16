//
//  DateFormatter.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 22.09.2023.
//

import Foundation

extension DateFormatter {
    static func dateToShortString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: date)
    }
}
