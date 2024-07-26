//
//  AddPostView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/26/24.
//

import SwiftUI

struct AddPostView: View {
    @StateObject private var vm: AddPostVM
    
    init(event: Event) {
        self._vm = StateObject(wrappedValue: AddPostVM(event: event))
    }
    
    init(_ idOrData: IdOrData<PlaceEssentials>) {
        switch idOrData {
        case .id(let placeId):
            self._vm = StateObject(wrappedValue: AddPostVM(placeId: placeId))
        case .data(let place):
            self._vm = StateObject(wrappedValue: AddPostVM(place: place))
        }
        
    }
    
    init(mapPlace: MapPlace) {
        self._vm = StateObject(wrappedValue: AddPostVM(mapPlace: mapPlace))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
        
    private var header: some View {
        VStack {
            HStack {
                if let event = vm.event, let logo = event.logo {
                    ImageLoader(logo, contentMode: .fit) { _ in
                        Image(systemName: "arrow.down.circle.dotted")
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(spacing: 10) {
                    Text(vm.event?.name ?? vm.place?.name ?? "Name Placeholder")
                        .cfont(.body)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    
                    Group {
                        if let place = vm.place {
                            if let address = place.location.address {
                                Text(address)
                            } else {
                                Text("Address placeholder")
                                    .redacted(reason: .placeholder)
                                    .onAppear {
                                        vm.updatePlaceLocationInfo()
                                    }
                            }
                        } else {
                            Text("Address placeholder")
                        }
                    }
                    .lineLimit(1)
                    .cfont(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(vm.place?.thumbnail != nil ? Color.white.opacity(0.85) : Color.secondary)
                }
                .foregroundStyle(vm.place?.thumbnail != nil ? Color.white : Color.primary)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .redacted(reason: vm.place == nil ? .placeholder : [])
            
            Divider()
        }
        .frame(maxWidth: .infinity)
        .background {
            if let thumbnail = vm.place?.thumbnail {
                ImageLoader(thumbnail, contentMode: .fill) { _ in
                    Image(systemName: "arrow.down.circle.dotted")
                        .foregroundStyle(Color.white.opacity(0.5))
                }
                .ignoresSafeArea()
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
            }
        }
        .background(Color.themePrimary)
    }
}

#Preview {
    let place = PlaceEssentials(
        id: "645c1d1ab41f8e12a0d166bc",
        name: "Eleven Madison Park",
        location: PlaceLocation(
            geoLocation: PlaceLocation.GeoLocation(lng: -73.9872074872255, lat: 40.7416907417333),
            address: nil,
            city: "New York",
            state: "NY",
            country: "US",
            zip: "10010"
        ),
        thumbnail: URL(string: "https://lh3.googleusercontent.com/p/AF1QipORpCE38GEBjvmFeP2fO3yrHfKLjVb_wswX-Y_N=s680-w680-h510"),
        categories: []
    )
    
    let event = Event(id: "662fa397516a809bf7b46f77", name: "Rich Ventures", description: "Lorem ipsum dolor sit amet.\nconsectetur adipiscing elit.\nsed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", logo: URL(string: "https://phantom-localdev.s3.us-west-1.amazonaws.com/events/RichVenturesLogo.jpg"), place: place)
    
    return AddPostView(event: event)
}
