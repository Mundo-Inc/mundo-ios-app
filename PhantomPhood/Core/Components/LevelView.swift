//
//  LevelView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 17.09.2023.
//

import SwiftUI


struct LevelView: View {
    let level: Int
    
    var body: Image {
        Image(level < 0 ? "NoLevel" : "Lvl\(level)", bundle: Bundle(path: "Levels"))
            .resizable()
    }
}

#Preview {
    LevelView(level: 5)
        .aspectRatio(contentMode: .fit)
        .frame(width: 50, height: 50)
        
}
