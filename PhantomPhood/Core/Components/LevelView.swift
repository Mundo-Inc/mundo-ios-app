//
//  LevelView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 17.09.2023.
//

import SwiftUI

enum Level: String, CaseIterable {
    case L1 = "Level1"
    case L2 = "Level2"
    case L3 = "Level3"
    case L4 = "Level4"
    case L5 = "Level5"
    case L6 = "Level6"
    case L7 = "Level7"
    case NoLevel = "NoLevel"
    
    static func convert(level: Int) -> Self {
        if level > 0 && level < self.allCases.count {
            return self.allCases[level - 1]
        } else {
            return self.NoLevel
        }
    }
}

struct LevelView: View {
    let level: Level
    
    var body: Image {
        Image(level.rawValue, bundle: Bundle(path: "Levels"))
            .resizable()
    }
}

#Preview {
    LevelView(level: .convert(level: 5))
}
