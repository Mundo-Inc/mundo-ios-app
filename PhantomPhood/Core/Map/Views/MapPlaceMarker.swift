//
//  MapPlaceMarker.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/12/23.
//

import SwiftUI

struct MapPlaceMarker: View {
    let place: RegionPlace
    
    var body: some View {
        NavigationLink(value: AppRoute.place(id: place.id)) {
            ZStack {
                Image(.mapMarkerBG)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(place.amenity?.color ?? PlaceAmenity.restaurant.color)
                
                Image(.mapMarkerStroke)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                
                Group {
                    Image(systemName: place.amenity?.image ?? PlaceAmenity.restaurant.image)
                }
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .padding(.bottom, 4)
            }
            .frame(width: 40)
        }
    }
}

#Preview {
    MapPlaceMarker(place: RegionPlace(_id: "", name: "MEME", amenity: .cafe, longitude: 40.7128, latitude: 74.0060, overallScore: 4, phantomScore: 86))
}
