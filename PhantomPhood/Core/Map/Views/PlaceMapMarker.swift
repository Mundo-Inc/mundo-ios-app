//
//  MapMarker.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 19.09.2023.
//

import SwiftUI

enum PlaceMarkerType {
    case restaurant
    case bar
    case cafe
    case cluster(count: Int)
    
    var color: Color {
        switch self {
        case .restaurant:
            return Color(red: 1, green: 0.63, blue: 0.21)
        case .bar:
            return Color(red: 1, green: 0.3, blue: 0.3)
        case .cafe:
            return Color(red: 0.44, green: 0.23, blue: 0)
        case .cluster:
            return Color(red: 0.44, green: 0.44, blue: 0.44)
        }
    }
}
//cup.and.saucer
struct PlaceMapMarker: View {
    let type: PlaceMarkerType
    
    var body: some View {
        ZStack {
            Image(.mapMarkerBG)
                .resizable()
                .scaledToFit()
                .foregroundStyle(type.color)
            
            Image(.mapMarkerStroke)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)

            Group {
                switch type {
                case .restaurant:
                    Image(systemName: "fork.knife")
                case .bar:
                    Image(systemName: "wineglass")
                case .cafe:
                    Image(systemName: "cup.and.saucer.fill")
                case .cluster(let count):
                    Text("\(count)")
                        .font(.headline)
                }
            }
            .font(.system(size: 20))
            .foregroundStyle(.white)
            .padding(.bottom, 4)
        }
        
        .frame(width: 40)
    }
}

#Preview {
    PlaceMapMarker(type: .cluster(count: 20))
}
