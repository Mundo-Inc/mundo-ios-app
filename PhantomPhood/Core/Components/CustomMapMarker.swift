//
//  CustomMapMarker.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/16/24.
//

import SwiftUI

struct CustomMapMarker: View {
    let image: Image?
    
    var body: some View {
        Circle()
            .foregroundStyle(Color.accentColor)
            .frame(width: 30, height: 30)
            .overlay {
                ZStack {
                    Circle()
                        .stroke(Color.themePrimary)
                    
                    if let image {
                        image
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "mappin")
                            .foregroundStyle(.white)
                    }
                }
            }
    }
}

#Preview {
    CustomMapMarker(image: nil)
}
