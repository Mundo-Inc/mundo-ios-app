//
//  PlaceSelectorView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/15/24.
//

import SwiftUI
import MapKit

struct PlaceSelectorView<Content>: View where Content : View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var placeSelectorVM = PlaceSelectorVM.shared
    
    var isLocationAvailable: Bool {
        locationManager.location != nil
    }
    
    var header: Content
    init(@ViewBuilder header: () -> Content = {EmptyView()}) {
        self.header = header()
    }
    
    @FocusState var textFocused
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 30, height: 4)
                .foregroundStyle(.tertiary)
                .padding(.vertical, 7)
            
            HStack(spacing: -14) {
                ForEach(placeSelectorVM.tokens) { token in
                    Label(
                        title: {
                            switch token {
                            case .checkin: Text(SearchTokens.checkin.rawValue)
                            case .addReview: Text(SearchTokens.addReview.rawValue)
                            }
                        },
                        icon: { Image(systemName: "xmark") }
                    )
                    .animation(.spring, value: placeSelectorVM.tokens.isEmpty)
                    .transition(.push(from: .trailing))
                    .font(.custom(style: .caption))
                    .bold()
                    .foregroundStyle(Color.accentColor)
                    .padding(.vertical, 10.9)
                    .padding(.horizontal, 5)
                    .background(Color.themePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .zIndex(10)
                    .shadow(radius: 10)
                    .onTapGesture {
                        withAnimation {
                            placeSelectorVM.tokens.removeAll()
                        }
                    }
                }
                
                ZStack {
                    TextField("Search", text: $placeSelectorVM.text)
                        .withFilledStyle(size: .small, paddingLeading: placeSelectorVM.tokens.isEmpty ? 34 : 20)
                        .textInputAutocapitalization(.never)
                        .animation(.spring, value: placeSelectorVM.tokens.isEmpty)
                        .focused($textFocused)
                    
                    if placeSelectorVM.tokens.isEmpty {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .padding(.leading, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.secondary)
                            .transition(.push(from: .leading))
                    }
                }
            }
            .padding(.horizontal)
            .onAppear {
                textFocused = true
            }
            
            VStack(spacing: 0) {
                HStack {
                    Text("Region")
                    
                    Spacer()
                    
                    Label {
                        Text(isLocationAvailable ? "Near you" : "Global")
                    } icon: {
                        Image(systemName: isLocationAvailable ? "location.fill" : "globe")
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .font(.custom(style: .body))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.themePrimary.opacity(0.5))
                .clipShape(.rect(cornerRadius: 4))
                .padding(.horizontal)
                
                Divider()
                    .padding(.top)
                
                List(placeSelectorVM.results, id: \.self) { place in
                    PlaceCard(place: place, dismiss: dismiss)
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
            }
            .opacity(placeSelectorVM.isLoading ? 0.6 : 1)
        }
        .presentationDetents([.fraction(0.99)])
    }
}

fileprivate struct PlaceCard: View {
    @ObservedObject var placeSelectorVM = PlaceSelectorVM.shared
    
    let place: MKMapItem
    let dismiss: DismissAction
    
    var body: some View {
        Button {
            dismiss()
            if let onSelect = placeSelectorVM.onSelect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onSelect(place)
                }
            }
        } label: {
            HStack {
                Circle()
                    .foregroundStyle(Color.themePrimary)
                    .frame(width: 42, height: 42)
                    .overlay {
                        Group {
                            if let pointOfInterestCategory = place.pointOfInterestCategory {
                                switch pointOfInterestCategory {
                                case .restaurant:
                                    Image(systemName: "fork.knife.circle.fill")
                                case .cafe:
                                    Image(systemName: "cup.and.saucer.fill")
                                case .bakery:
                                    Image(systemName: "storefront.fill")
                                case .nightlife:
                                    Image(systemName: "mug.fill")
                                case .winery:
                                    Image(systemName: "wineglass.fill")
                                default:
                                    Image(systemName: "mappin.circle")
                                }
                            }
                            else {
                                Image(systemName: "mappin.circle")
                            }
                        }
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                    }
                
                VStack {
                    Text(place.name ?? place.placemark.name ?? "Unknown")
                        .font(.custom(style: .body))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let distance = distanceFromMe(lat: place.placemark.coordinate.latitude, lng: place.placemark.coordinate.longitude, unit: .miles) {
                        Text(String(format: "%.1f", distance) + " Miles away")
                            .font(.custom(style: .caption))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("-")
                            .font(.custom(style: .caption))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
