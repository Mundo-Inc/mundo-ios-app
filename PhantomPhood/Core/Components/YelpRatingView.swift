//
//  YelpRatingView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/3/23.
//

import SwiftUI

struct YelpRatingView: View {
    let rating: Double?
    
    var body: some View {
        if let rating = rating {
            switch rating {
            case 0..<1:
                Image("YelpRating_0")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 1..<1.5:
                Image("YelpRating_1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 1.5..<2:
                Image("YelpRating_1_half")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 2..<2.5:
                Image("YelpRating_2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 2.5..<3:
                Image("YelpRating_2_half")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 3..<3.5:
                Image("YelpRating_3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 3.5..<4:
                Image("YelpRating_3_half")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 4..<4.5:
                Image("YelpRating_4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 4.5..<5:
                Image("YelpRating_4_half")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case 5:
                Image("YelpRating_5")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            default:
                Image("YelpRating_0")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            Image("YelpRating_0")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .redacted(reason: .placeholder)
                .clipShape(.rect(cornerRadius: 4))
        }
    }
}

#Preview {
    HStack {
        YelpRatingView(rating: nil)
        YelpRatingView(rating: 5)
    }
    .padding(.horizontal)
}
