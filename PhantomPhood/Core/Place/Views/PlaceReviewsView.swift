//
//  PlaceReviewsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/3/23.
//

import SwiftUI

struct PlaceReviewsView: View {
    @ObservedObject private var placeVM: PlaceVM
    @StateObject private var vm: PlaceReviewsVM
    
    init(placeVM: PlaceVM) {
        self._vm = StateObject(wrappedValue: PlaceReviewsVM(placeVM: placeVM))
        self._placeVM = ObservedObject(wrappedValue: placeVM)
    }
    
    var body: some View {
        VStack {
            if placeVM.place != nil {
                Group {
                    if let total = vm.total {
                        if total == 0 {
                            Text("No \(K.appName) Review")
                        } else {
                            Text(total > 1 ? "\(total.formattedWithSuffix()) \(K.appName) Reviews" : "1 \(K.appName) Review")
                        }
                    } else {
                        Text("10 \(K.appName) Reviews")
                            .redacted(reason: .placeholder)
                    }
                }
                .cfont(.caption)
                .foregroundStyle(.secondary)
                
                LazyVStack {
                    if vm.reviews.isEmpty && vm.total == nil {
                        ForEach(RepeatItem.create(3)) { _ in
                            PlaceReviewItem.placeholder
                                .padding(.horizontal)
                        }
                    }
                    
                    ForEach($vm.reviews) { $review in
                        PlaceReviewItem(review: $review, placeVM: placeVM)
                    }
                    
                    if let googleReviews = vm.googleReviews {
                        ForEach(googleReviews.indices, id: \.self) { index in
                            GoogleReviewItem(review: googleReviews[index])
                        }
                    } else {
                        PlaceReviewItem.placeholder
                            .padding(.horizontal)
                            .task {
                                await vm.fetchGooglePlacesReviews()
                            }
                    }
                    
                    if let yelpReviews = vm.yelpReviews {
                        ForEach(yelpReviews) { review in
                            YelpReviewItem(review: review)
                        }
                    } else {
                        PlaceReviewItem.placeholder
                            .padding(.horizontal)
                            .task {
                                await vm.fetchYelpReviews()
                            }
                    }
                    
                    Spacer()
                }
                .frame(minHeight: 200)
                .padding(.bottom, 30)
                .task {
                    await vm.fetch(.refresh)
                }
            } else {
                Text("10 \(K.appName) Reviews")
                    .cfont(.caption)
                    .foregroundStyle(.secondary)
                    .redacted(reason: .placeholder)
                
                ForEach(RepeatItem.create(3)) { _ in
                    PlaceReviewItem.placeholder
                        .padding(.horizontal)
                }
            }
        }
        .padding(.top)
        .background(Color.themePrimary)
    }
}

#Preview {
    PlaceReviewsView(placeVM: PlaceVM(data: Placeholder.placeDetails[0], action: nil))
}
