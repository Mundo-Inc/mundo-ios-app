//
//  String.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/15/24.
//

import Foundation

extension String {
    var isSingleEmoji: Bool {
        return self.count == 1 && self.containsEmoji
    }
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                0x1F680...0x1F6FF, // Transport and Map
                0x1F700...0x1F77F, // Alchemical Symbols
                0x2600...0x26FF,   // Misc symbols
                0x2700...0x27BF,   // Dingbats
                0xFE00...0xFE0F,   // Variation Selectors
                0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                0x1FA70...0x1FAFF, // Symbols and Pictographs Extended-A
                0x3300...0x33FF:   // CJK Compatibility
                return true
            default:
                continue
            }
        }
        return false
    }
}

extension String {
    func formatPhoneNumber() -> (number: String, country: Country?) {
        let country: Country?
        var cleanNumber: String
        
        if hasPrefix("+") {
            guard count >= 5 else {
                return (self, nil)
            }
            
            let number = numbersOnly
            
            if let found = Country.find(phoneNumber: "+\(number)") {
                country = found
                cleanNumber = "+\(number)".replacingOccurrences(of: found.dialCode, with: "")
            } else {
                country = nil
                cleanNumber = number
            }
        } else {
            country = nil
            cleanNumber = numbersOnly
        }
        
        while cleanNumber.hasPrefix("0") {
            cleanNumber = String(cleanNumber.dropFirst())
        }
        
        let mask = "(XXX) XXX-XXXX"
        
        var result = ""
        var startIndex = cleanNumber.startIndex
        let endIndex = cleanNumber.endIndex
        
        for char in mask where startIndex < endIndex {
            if char == "X" {
                result.append(cleanNumber[startIndex])
                startIndex = cleanNumber.index(after: startIndex)
            } else {
                result.append(char)
            }
        }
        
        return (result, country)
    }
    
    var numbersOnly: String {
        components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^\\+[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidPassword: Bool {
        count > 5
    }
}
