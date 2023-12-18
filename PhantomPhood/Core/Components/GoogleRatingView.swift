//
//  GoogleRatingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/2/23.
//

import SwiftUI

struct GoogleRatingView: View {
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
            
            HStack {
                VStack(alignment: .leading) {
                    StarRating(score: (rating != nil ? rating! : 0), activeColor: .yellow)
                    
                    Spacer()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(rating == nil ? "0" : Int((rating! * 10)) % 10 == 0 ? String(format: "%.f", rating!) : String(format: "%.1f", rating!))
                        Text("/5")
                            .foregroundStyle(.secondary)
                        
                        if let count = reviewCount {
                            Text("(\(count > 1000 ? String(format: "%.1f", Double(count) / 1000) + "K" : String(count)))")
                                .padding(.leading, 5)
                                .foregroundStyle(.secondary)
                                .font(.custom(style: .caption))
                        }
                    }
                    .font(.custom(style: .headline))
                }
                .redacted(reason: isLoading ? .placeholder : [])
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(.googleLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(height: 70)
    }
}

#Preview {
    VStack {
        HStack {
            GoogleRatingView(rating: nil, isLoading: true)
            GoogleRatingView(rating: nil, isLoading: false)
        }
        HStack {
            GoogleRatingView(rating: 4, isLoading: true)
            GoogleRatingView(rating: 4, reviewCount: 2500, isLoading: false)
        }
    }
    .padding(.horizontal)
}
