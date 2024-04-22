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
            .shadow(radius: 3)
            .overlay {
                Circle()
                    .stroke(Color.themePrimary)
                
                Group {
                    if let image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "mappin")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(width: 20, height: 20)
                .foregroundStyle(.white)
            }
    }
}

#Preview {
    CustomMapMarker(image: nil)
}
