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
