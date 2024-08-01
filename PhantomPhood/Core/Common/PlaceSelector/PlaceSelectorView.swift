//
//  PlaceSelectorView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import SwiftUI
import MapKit

struct PlaceSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var locationManager = LocationManager.shared
    @StateObject private var vm = PlaceSelectorVM()
    
    private let onSelect: (MKMapItem) -> Void
    
    init(onSelect: @escaping (MKMapItem) -> Void) {
        self.onSelect = onSelect
    }
    
    @FocusState private var textFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Checking In")
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                Text("Choose your check-in location.")
                    .cfont(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 0) {
                    Image(.Icons.search)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .frame(width: 46, height: 46)
                        .foregroundStyle(.tertiary)
                    
                    TextField("Search Places", text: $vm.text)
                        .frame(maxWidth: .infinity)
                        .textInputAutocapitalization(.never)
                        .focused($textFocused)
                    
                    HStack(spacing: 5) {
                        Group {
                            if locationManager.location == nil {
                                Image(systemName: "globe")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image(.Icons.compass)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .frame(width: 22, height: 22)
                        .foregroundStyle(.tertiary)
                        
                        Text(locationManager.location != nil ? "Near You" : "Global")
                    }
                    .cfont(.subheadline)
                    .foregroundStyle(.tertiary)
                    .padding(.trailing)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.themePrimary, in: .rect(cornerRadius: 50))
                .contentShape(RoundedRectangle(cornerRadius: 50))
                .onTapGesture {
                    textFocused = true
                }
                .padding(.top, 8)
            }
            .padding()
            .padding(.top, 8)
            
            Divider()
                .padding(.horizontal)
            
            if vm.results.isEmpty && vm.isLoading {
                List {
                    PlaceCard.placeholder
                    PlaceCard.placeholder
                    PlaceCard.placeholder
                    PlaceCard.placeholder
                    PlaceCard.placeholder
                    PlaceCard.placeholder
                    PlaceCard.placeholder
                    PlaceCard.placeholder
                }
                .listStyle(PlainListStyle())
                .scrollDismissesKeyboard(.interactively)
                .opacity(0.6)
            } else {
                List(vm.results, id: \.self) { place in
                    PlaceCard(place: place, onSelect: onSelect)
                }
                .listStyle(PlainListStyle())
                .scrollDismissesKeyboard(.interactively)
                .opacity(vm.isLoading ? 0.6 : 1)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            textFocused = true
        }
    }
}

fileprivate struct PlaceCard: View {
    @Environment(\.dismiss) private var dismiss
    
    private let place: MKMapItem
    private let onSelect: (MKMapItem) -> Void
    
    init(place: MKMapItem, onSelect: @escaping (MKMapItem) -> Void) {
        self.place = place
        self.onSelect = onSelect
    }
    
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
                    
                    Group {
                        if let distance = distanceFromMe(lat: place.placemark.coordinate.latitude, lng: place.placemark.coordinate.longitude, unit: .miles) {
                            Text(String(format: "%.1f", distance) + " Miles away")
                        } else {
                            Text(place.placemark.getAddress(ofType: .local) ?? "-")
                            
                        }
                    }
                    .cfont(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
        .listRowBackground(Color.clear)
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        .alignmentGuide(.listRowSeparatorTrailing) { $0[.trailing] }
    }
    
    static var placeholder: some View {
        HStack {
            Image(systemName: "mappin.circle")
                .font(.system(size: 24))
                .frame(width: 42, height: 42)
                .foregroundStyle(.secondary)
            
            VStack {
                Text("Placeholder Name")
                    .cfont(.body)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 18)
                
                Text("0.1 Miles away")
                    .foregroundStyle(.secondary)
                    .cfont(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .redacted(reason: .placeholder)
        .foregroundStyle(.primary)
        .listRowBackground(Color.clear)
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        .alignmentGuide(.listRowSeparatorTrailing) { $0[.trailing] }
    }
}

#Preview {
    ZStack {
        Rectangle()
            .foregroundStyle(Color.themeBG.gradient)
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                PlaceSelectorView { mapItem in
                    print(mapItem)
                }
            }
    }
}
