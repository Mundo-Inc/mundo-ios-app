//
//  PlaceIcon.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/30/23.
//

import SwiftUI

struct PlaceIcon: View {
    let amenity: PlaceAmenity
    let size: CGFloat
    
    init(amenity: PlaceAmenity?, size: CGFloat = 40) {
        self.amenity = amenity ?? .restaurant
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Image(.mapMarkerBG)
                .resizable()
                .scaledToFit()
                .foregroundStyle(amenity.color)
            
            Image(.mapMarkerStroke)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
            
            Group {
                Image(systemName: amenity.image)
            }
            .font(.system(size: size / 2.3))
            .foregroundStyle(.white)
            .padding(.bottom, 4)
        }
        .frame(width: size)
    }
}

#Preview {
    PlaceIcon(amenity: .restaurant)
}
