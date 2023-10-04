//
//  YelpRatingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/3/23.
//

import SwiftUI

struct YelpRatingView: View {
    let rating: Double?
    let reviewCount: Int?
    let isLoading: Bool
    
    init(rating: Double?, reviewCount: Int? = nil, isLoading: Bool = false) {
        self.rating = rating
        self.reviewCount = reviewCount
        self.isLoading = isLoading
    }
    
    var body: some View {
        ZStack {
            Color(.ratingsBG)
                .shadow(color: Color.black.opacity(0.15), radius: 8)
                .clipShape(.rect(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                if let rating = rating, let ratingImage = yelpScoreDict[rating] {
                    Image(ratingImage)
                } else {
                    Image("YelpRating_0")
                        .redacted(reason: isLoading ? .placeholder : [])
                }
                
                HStack {
                    if let count = reviewCount {
                        Text("\(count > 1000 ? String(format: "%.1f", Double(count) / 1000) + "K" : String(count)) Reviews")
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No rating")
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                            .redacted(reason: isLoading ? .placeholder : [])
                    }
                    
                    Spacer()
                    
                    Image(.yelpLogo)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
            .padding(.top, 12)
            .clipShape(.rect(cornerRadius: 8))
        }
        .frame(height: 70)
    }
    
    let yelpScoreDict: [Double: String] = [
        0: "YelpRating_0",
        1: "YelpRating_1",
        1.5: "YelpRating_1_half",
        2: "YelpRating_2",
        2.5: "YelpRating_2_half",
        3: "YelpRating_3",
        3.5: "YelpRating_3_half",
        4: "YelpRating_4",
        4.5: "YelpRating_4_half",
        5: "YelpRating_5"
    ]
}

#Preview {
    VStack {
        HStack {
            YelpRatingView(rating: nil, isLoading: true)
            YelpRatingView(rating: nil, isLoading: false)
        }
        HStack {
            YelpRatingView(rating: 4, isLoading: true)
            YelpRatingView(rating: 5, reviewCount: 2500, isLoading: false)
        }
    }
    .padding(.horizontal)
}
