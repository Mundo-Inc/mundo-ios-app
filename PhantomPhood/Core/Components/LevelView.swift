//
//  LevelView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 17.09.2023.
//

import SwiftUI


struct LevelView: View {
    let level: Int
    
    var body: some View {
        Image(level < 0 ? "NoLevel" : "Lvl\(level)", bundle: Bundle(path: "Levels"))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    LevelView(level: 5)
        .frame(width: 50, height: 50)
        
}
