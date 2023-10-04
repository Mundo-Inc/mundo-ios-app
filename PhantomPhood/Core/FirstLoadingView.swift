//
//  FirstLoadingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import SwiftUI

struct FirstLoadingView: View {
    var body: some View {
        ZStack {
            CircleLabelView(text: "BY FOODIES ● FOR FOODIES ● ")
                .frame(width: 200, height: 200)
                .foregroundStyle(Color.accentColor)
            
            ProgressView()
                .foregroundStyle(Color.accentColor)
        }
    }
}

#Preview {
    FirstLoadingView()
}
