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
        NavigationLink(value: MapStack.place(id: place.id)) {
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


//struct PlaceMapMarker: View {
////    let place: RegionPlace
//    
//    var body: some View {
//        ZStack {
//            Image(.mapMarkerBG)
//                .resizable()
//                .scaledToFit()
////                .foregroundStyle(place.amenity?.color ?? Color.black)
//            
//            Image(.mapMarkerStroke)
//                .resizable()
//                .scaledToFit()
//                .foregroundStyle(.white)
//
//            Group {
//                switch type {
//                case .restaurant:
//                    Image(systemName: "fork.knife")
//                case .bar:
//                    Image(systemName: "wineglass")
//                case .cafe:
//                    Image(systemName: "cup.and.saucer.fill")
//                case .cluster(let count):
//                    Text("\(count)")
//                        .font(.headline)
//                }
//            }
//            .font(.system(size: 20))
//            .foregroundStyle(.white)
//            .padding(.bottom, 4)
//        }
//        .frame(width: 40)
//    }
//}
//
//#Preview {
////    PlaceMapMarker(place: RegionPlace(_id: "", name: "MEME", amenity: .cafe, longitude: 40.7128, latitude: 74.0060, overallScore: 4, phantomScore: 86))
//    PlaceMapMarker()
//}
