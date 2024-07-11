//
//  PlaceSelectorView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import SwiftUI
import MapKit

struct PlaceSelectorView: View {
    @ObservedObject private var locationManager = LocationManager.shared
    
    @StateObject private var vm = PlaceSelectorVM()
    
    private let onSelect: (MKMapItem) -> Void
    
    init(onSelect: @escaping (MKMapItem) -> Void) {
        self.onSelect = onSelect
    }
    
    @FocusState private var textFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                TextField(text: $vm.text) {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .withFilledStyle(size: .medium, paddingTrailing: 95)
                .textInputAutocapitalization(.never)
                .focused($textFocused)
                
                Label {
                    Text(locationManager.location != nil ? "Near you" : "Global")
                } icon: {
                    Image(systemName: locationManager.location != nil ? "location.fill" : "globe")
                }
                .cfont(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 10)
            }
            .padding()
            .onAppear {
                textFocused = true
            }
            
            Divider()
            
            List(vm.results, id: \.self) { place in
                PlaceCard(place: place, onSelect: onSelect)
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.interactively)
            .opacity(vm.isLoading ? 0.6 : 1)
        }
        .presentationDetents([.fraction(0.99)])
    }
}

fileprivate struct PlaceCard: View {
    @Environment(\.dismiss) private var dismiss
    
    let place: MKMapItem
    let onSelect: (MKMapItem) -> Void
    
    var body: some View {
        Button {
            dismiss()
            onSelect(place)
        } label: {
            HStack {
                Group {
                    if let pointOfInterestCategory = place.pointOfInterestCategory {
                        pointOfInterestCategory.image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "mappin.circle")
                            .font(.system(size: 24))
                    }
                }
                .frame(width: 42, height: 42)
                .foregroundStyle(.secondary)
                
                VStack {
                    Text(place.name ?? place.placemark.name ?? "Unknown")
                        .cfont(.body)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 18)
                    
                    if let distance = distanceFromMe(lat: place.placemark.coordinate.latitude, lng: place.placemark.coordinate.longitude, unit: .miles) {
                        Text(String(format: "%.1f", distance) + " Miles away")
                            .foregroundStyle(.secondary)
                            .cfont(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("\(place.placemark.postalAddress?.city ?? "-"), \(place.placemark.postalAddress?.street ?? "-")")
                            .cfont(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
