//
//  PlaceReviewsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/3/23.
//

import SwiftUI

struct PlaceReviewsView: View {
    @ObservedObject var vm: PlaceViewModel
    @ObservedObject var addReviewVM = AddReviewVM.shared
    
    @StateObject var placeReviewsVM: PlaceReviewsViewModel
    
    init(placeId: String, vm: PlaceViewModel) {
        self.vm = vm
        self._placeReviewsVM = StateObject(wrappedValue: PlaceReviewsViewModel(placeId: placeId))
    }
    
    @StateObject var mediasViewModel = MediasViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Text("Overall score")
                    .font(.custom(style: .headline))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Grid {
                    if let drinkQuality = vm.place?.scores.drinkQuality {
                        GridRow {
                            Text("Drink Quality")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.leading)
                            
                            PlaceScoreRange(score: drinkQuality)
                            
                            Text(String(format: "%.1f", drinkQuality))
                                .gridColumnAlignment(.trailing)
                        }
                    }
                    if let foodQuality = vm.place?.scores.foodQuality {
                        GridRow {
                            Text("Food Quality")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.leading)
                            
                            PlaceScoreRange(score: foodQuality)
                            
                            Text(String(format: "%.1f", foodQuality))
                                .gridColumnAlignment(.trailing)
                        }
                    }
                    if let atmosphere = vm.place?.scores.atmosphere {
                        GridRow {
                            Text("Atmosphere")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.leading)
                            
                            PlaceScoreRange(score: atmosphere)
                            
                            Text(String(format: "%.1f", atmosphere))
                                .gridColumnAlignment(.trailing)
                        }
                    }
                    if let service = vm.place?.scores.service {
                        GridRow {
                            Text("Service")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.leading)
                            
                            PlaceScoreRange(score: service)
                            
                            Text(String(format: "%.1f", service))
                                .gridColumnAlignment(.trailing)
                        }
                    }
                    if let value = vm.place?.scores.value {
                        GridRow {
                            Text("Value")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.leading)
                            
                            PlaceScoreRange(score: value)
                            
                            Text(String(format: "%.1f", value))
                                .gridColumnAlignment(.trailing)
                        }
                    }
                }
                .font(.custom(style: .body))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                
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
                        
                        Spacer()
                        
                        Button {
                            if let place = vm.place {
                                addReviewVM.present(place: place)
                            }
                        } label: {
                            Label(
                                title: { Text("Add Review") },
                                icon: { Image(systemName: "text.bubble.rtl") }
                            )
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .font(.custom(style: .headline))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Divider()
                    
                    ForEach(placeReviewsVM.reviews.indices, id: \.self) { index in
                        PlaceReviewView(placeReviewsVM: placeReviewsVM, reviewIndex: index, mediasViewModel: mediasViewModel, reportId: $vm.reportId)
                            .padding(.horizontal)
                        
                        Divider()
                    }
                }
                .padding(.top)
            }
            .redacted(reason: vm.place == nil ? .placeholder : [])
        }
        .padding(.top)
        .fullScreenCover(isPresented: $mediasViewModel.show, content: {
            MediasView(vm: mediasViewModel)
        })
    }
}

#Preview {
    PlaceReviewsView(placeId: "645c1d1ab41f8e12a0d166bc", vm: PlaceViewModel(id: "645c1d1ab41f8e12a0d166bc"))
}
