//
//  CheckInCard.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/29/24.
//

import SwiftUI

struct CheckInCard: View {
    private let place: PlaceOverview?
    private let checkin: FeedCheckin?
    
    init(data: FeedItem) {
        if let place = data.place {
            self.place = place
        } else {
            self.place = nil
        }
        if case .checkin(let checkin) = data.resource {
            self.checkin = checkin
        } else {
            self.checkin = nil
        }
    }
    
    var body: some View {
        if let checkin, let place {
            VStack {
                NavigationLink(value: AppRoute.place(id: place.id)) {
                    if let image = checkin.image, let url = image.src {
                        ZStack {
                            ImageLoader(url, contentMode: .fill) { progress in
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(maxWidth: 150)
                                    .overlay {
                                        ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                            .progressViewStyle(LinearProgressViewStyle())
                                    }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                            if checkin.caption != nil || (checkin.tags != nil && !checkin.tags!.isEmpty) {
                                VStack(spacing: 5) {
                                    VStack {
                                        Text(place.name)
                                            .foregroundStyle(Color.white)
                                            .lineLimit(1)
                                            .font(.custom(style: .subheadline))
                                            .foregroundStyle(.primary)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack {
                                            if let phantomScore = place.scores.phantom {
                                                Text("👻 \(String(format: "%.0f", phantomScore))")
                                                    .bold()
                                                    .foregroundStyle(Color.accentColor)
                                            }
                                            
                                            if let priceRange = place.priceRange {
                                                if place.scores.phantom != nil {
                                                    Circle()
                                                        .frame(width: 4, height: 4)
                                                        .foregroundStyle(Color.white.opacity(0.4))
                                                }
                                                
                                                Text(String(repeating: "$", count: priceRange))
                                            }
                                        }
                                        .font(.custom(style: .subheadline))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Spacer()
                                    
                                    if let tags = checkin.tags {
                                        ForEach(tags) { user in
                                            HStack(spacing: 3) {
                                                ProfileImage(user.profileImage, size: 22)
                                                Text("@\(user.username)")
                                                    .font(.custom(style: .caption))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                    }
                                    
                                    if let caption = checkin.caption, !caption.isEmpty {
                                        Text(caption)
                                            .font(.custom(style: .caption))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(6)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding()
                                .background {
                                    LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.4), .clear, .clear, .black.opacity(0.4), .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        VStack(spacing: 5) {
                            HStack {
                                Image(systemName: "checkmark.diamond.fill")
                                    .font(.system(size: 36))
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(LinearGradient(colors: [Color.green, Color.accentColor], startPoint: .topLeading, endPoint: .trailing))
                                
                                VStack {
                                    Text(place.name)
                                        .lineLimit(1)
                                        .font(.custom(style: .subheadline))
                                        .foregroundStyle(.primary)
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        if let phantomScore = place.scores.phantom {
                                            Text("👻 \(String(format: "%.0f", phantomScore))")
                                                .bold()
                                                .foregroundStyle(Color.accentColor)
                                        }
                                        
                                        if let priceRange = place.priceRange {
                                            if place.scores.phantom != nil {
                                                Circle()
                                                    .frame(width: 4, height: 4)
                                                    .foregroundStyle(Color.primary.opacity(0.5))
                                            }
                                            
                                            Text(String(repeating: "$", count: priceRange))
                                        }
                                    }
                                    .font(.custom(style: .subheadline))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            if let tags = checkin.tags {
                                ForEach(tags) { user in
                                    HStack(spacing: 3) {
                                        ProfileImage(user.profileImage, size: 22)
                                        Text("@\(user.username)")
                                            .font(.custom(style: .caption))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            
                            if let caption = checkin.caption, !caption.isEmpty {
                                Text(caption)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.primary)
                                    .font(.custom(style: .caption))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themePrimary)
                        .clipShape(.rect(cornerRadius: 15))
                    }
                }
                .foregroundStyle(.primary)
                
                Text("\(checkin.totalCheckins) total checkins")
                    .foregroundStyle(.secondary)
                    .font(.custom(style: .caption))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        } else {
            if #available(iOS 17.0, *) {
                ContentUnavailableView("Something went wrong", image: "exclamationmark.triangle")
            } else {
                VStack {
                    Text("Something went wrong")
                    Image(systemName: "exclamationmark.triangle")
                }
            }
        }
    }
}

//#Preview {
//    CheckInCard()
//}
