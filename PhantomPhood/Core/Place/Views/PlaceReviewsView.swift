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
    
    @StateObject var mediasViewModel = MediasVM()
    
    var body: some View {
        VStack {
            Group {
                if let total = vm.total {
                    if total == 0 {
                        Text("No Phantom Review")
                    } else {
                        Text(total > 1 ? "\(total.formattedWithSuffix()) Phantom Reviews" : "1 Phantom Review")
                    }
                } else {
                    Text("10 Reviews")
                        .redacted(reason: .placeholder)
                }
            }
            .font(.custom(style: .caption))
            .foregroundStyle(.secondary)
            
            LazyVStack {
                if !vm.reviews.isEmpty {
                    ForEach($vm.reviews) { $review in
                        PlaceReviewItem(review: $review, placeVM: placeVM)
                    }
                } else if vm.total == nil {
                    Group {
                        RoundedRectangle(cornerRadius: 10)
                            .onAppear {
                                Task {
                                    await vm.fetch(.refresh)
                                }
                            }
                        RoundedRectangle(cornerRadius: 10)
                        RoundedRectangle(cornerRadius: 10)
                    }
                    .frame(height: 200)
                    .foregroundStyle(Color.themeBorder)
                    .padding(.horizontal)
                }
                
                if let googleReviews = placeVM.place?.thirdParty.google?.reviews, !googleReviews.isEmpty {
                    ForEach(googleReviews.indices, id: \.self) { index in
                        GoogleReviewItem(review: googleReviews[index])
                    }
                }
                
                if let yelpReviews = placeVM.place?.thirdParty.yelp?.reviews, !yelpReviews.isEmpty {
                    ForEach(yelpReviews) { review in
                        YelpReviewItem(review: review)
                    }
                }
                
                Spacer()
            }
            .frame(minHeight: 200)
            .padding(.bottom, 40)
        }
        .padding(.top)
        .background(Color.themePrimary)
        .redacted(reason: placeVM.place == nil ? .placeholder : [])
    }
}

#Preview {
    PlaceReviewsView(placeVM: PlaceVM(id: "645c1d1ab41f8e12a0d166bc"))
}
