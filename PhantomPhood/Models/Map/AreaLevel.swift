//
//  AreaLevel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/27/24.
//

import Foundation

enum AreaLevel: Double {
    case A = 16_000_000_000
    case B = 7_000_000_000_000
    case C = 2_000_000_000_000_000
    
    var areaUnit: Double {
        switch self {
        case .A:
            70000
        case .B:
            800000
        case .C:
            15000000
        }
    }
    
    static func categorizeArea(_ area: Double) -> AreaLevel {
        switch area {
        case 0..<AreaLevel.A.rawValue: return .A
        case AreaLevel.A.rawValue..<AreaLevel.B.rawValue: return .B
        default: return .C
        }
    }
}
