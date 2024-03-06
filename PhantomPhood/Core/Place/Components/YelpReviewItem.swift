//
//  YelpReviewItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/22/24.
//

import SwiftUI

struct YelpReviewItem: View {
    let review: YelpReview
    
    var body: some View {
        VStack {
            HStack {
                ProfileImage(review.user.imageUrl, size: 52, cornerRadius: 8)
                
                VStack(spacing: 2) {
                    HStack {
                        Text(review.user.name)
                            .font(.custom(style: .headline))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(review.timeCreated)
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        YelpRatingView(rating: Double(review.rating))
                            .frame(height: 16)
                        
                        Spacer()
                        
                        Image(.yelpLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                    }
                }
            }
            .padding(.horizontal)
            
            Text(review.text)
                .font(.custom(style: .body))
                .foregroundStyle(Color.primary.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            Divider()
        }
    }
}

//#Preview {
//    YelpReviewItem()
//}
