//
//  CircleLabelView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct CircleLabelView: View {
    let text: String
    
    var body: some View {
        ZStack {
            ForEach(Array(text.enumerated()), id: \.offset) { index, letter in
                VStack {
                    Text(String(letter))
                    Spacer()
                }
                .rotationEffect(.degrees(Double(index * 360 / text.count)))
            }
        }
        .font(.system(size: 14, design: .monospaced))
        .bold()
    }
}

#Preview {
    CircleLabelView(text: "TEXT * TEXT * TEXT * TEXT * ")
        .frame(width: 200, height: 200)
}
