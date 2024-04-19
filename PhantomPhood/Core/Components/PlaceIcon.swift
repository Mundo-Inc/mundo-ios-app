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
            
            amenity.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.65, height: size * 0.65)
                .foregroundStyle(.white)
                .padding(.bottom, 4)
        }
        .frame(width: size)
    }
}

#Preview {
    PlaceIcon(amenity: .restaurant)
}
