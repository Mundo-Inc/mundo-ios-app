//
//  PlaceReviewsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/3/23.
//

import SwiftUI

struct PlaceReviewsView: View {
    @ObservedObject var vm: PlaceViewModel
    
    @StateObject var placeReviewsViewModel: PlaceReviewsViewModel
    
    init(placeId: String, vm: PlaceViewModel) {
        self.vm = vm
        self._placeReviewsViewModel = StateObject(wrappedValue: PlaceReviewsViewModel(placeId: placeId))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text("Overall score")
                    .font(.custom(style: .headline))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    if let drinkQuality = vm.place?.scores.drinkQuality {
                        HStack {
                            Text("Drink Quality")
                                .foregroundStyle(.secondary)
                                .frame(width: 100, alignment: .leading)
                            
                            PlaceScoreRange(score: drinkQuality)
                            
                            HStack(spacing: 0) {
                                Text(String(format: "%.1f", drinkQuality))
                                Text("/5")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    if let foodQuality = vm.place?.scores.foodQuality {
                        HStack {
                            Text("Food Quality")
                                .foregroundStyle(.secondary)
                                .frame(width: 100, alignment: .leading)
                            
                            PlaceScoreRange(score: foodQuality)
                            
                            HStack(spacing: 0) {
                                Text(String(format: "%.1f", foodQuality))
                                Text("/5")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    if let atmosphere = vm.place?.scores.atmosphere {
                        HStack {
                            Text("Atmosphere")
                                .foregroundStyle(.secondary)
                                .frame(width: 100, alignment: .leading)
                            
                            PlaceScoreRange(score: atmosphere)
                            
                            HStack(spacing: 0) {
                                Text(String(format: "%.1f", atmosphere))
                                Text("/5")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    if let service = vm.place?.scores.service {
                        HStack {
                            Text("Service")
                                .foregroundStyle(.secondary)
                                .frame(width: 100, alignment: .leading)
                            
                            PlaceScoreRange(score: service)
                            
                            HStack(spacing: 0) {
                                Text(String(format: "%.1f", service))
                                Text("/5")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    if let value = vm.place?.scores.value {
                        HStack {
                            Text("Value")
                                .foregroundStyle(.secondary)
                                .frame(width: 100, alignment: .leading)
                            
                            PlaceScoreRange(score: value)
                            
                            HStack(spacing: 0) {
                                Text(String(format: "%.1f", value))
                                Text("/5")
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
                .font(.custom(style: .body))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                
                VStack {
                    HStack {
                        Text("Reviews")
                            .bold()
                        if let place = vm.place {
                            Text("(\(place.reviewCount > 1000 ? String(format: "%.1f", Double(place.reviewCount) / 1000) + "K" : String(place.reviewCount)))")
                        } else {
                            Text("100")
                                .redacted(reason: .placeholder)
                        }
                    }
                    .font(.custom(style: .headline))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let place = vm.place, !place.reviews.isEmpty {
                        ForEach(place.reviews) { review in
                            PlaceReviewView(review: review, place: place)
                        }
                    }
                }
                .padding(.top)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    PlaceReviewsView(placeId: "645c1d1ab41f8e12a0d166bc", vm: PlaceViewModel(id: "645c1d1ab41f8e12a0d166bc"))
        .padding(.horizontal)
}
