//
//  GoogleReviewItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/22/24.
//

import SwiftUI

struct GoogleReviewItem: View {
    let review: GoogleReview
    
    var body: some View {
        VStack {
            HStack {
                ProfileImage(review.authorAttribution.photoUri, size: 52, cornerRadius: 8)
                
                VStack(spacing: 2) {
                    HStack {
                        Text(review.authorAttribution.displayName)
                            .font(.custom(style: .headline))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(review.relativePublishTimeDescription)
                            .font(.custom(style: .caption))
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        StarRating(score: Double(review.rating), activeColor: Color.gold, size: 14)
                        
                        Spacer()
                        
                        Image(.googleLogo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 22)
                    }
                }
            }
            .padding(.horizontal)
            
            Text(review.text.text)
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
//    GoogleReviewItem()
//}
