//
//  MapActivityView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/15/23.
//

import SwiftUI
import Kingfisher

struct MapActivityView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appData = AppData.shared
    
    let placeDataManager = PlaceDM()
    
    @Binding var mapActivity: MapActivity?
    
    @State var place: Place? = nil
    @State var isLoading = false
    
    func getPlace(id: String) async {
        self.isLoading = true
        do {
            let data = try await placeDataManager.fetch(id: id)
            self.place = data
        } catch {
            print(error)
        }
        self.isLoading = false
    }
    
    var checkins: [MapActivity.ActivitiesData]? {
        if let mapActivity {
            return mapActivity.activities.data.filter({ $0.checkinsCount > 0 })
        } else {
            return nil
        }
    }
    
    var reviews: [MapActivity.ActivitiesData]? {
        if let mapActivity {
            return mapActivity.activities.data.filter({ $0.reviewsCount > 0 })
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(place?.name ?? "Place Name")
                    .multilineTextAlignment(.leading)
                
                if let place {
                    if let overallScore = place.scores.overall {
                        HStack(spacing: 0) {
                            Text("(")
                            Image(systemName: "star.fill")
                            Text(String(format: "%.1f", overallScore))
                            Text(")")
                        }
                    }
                    
                    if let priceRange = place.priceRange {
                        Text("|")
                            .foregroundStyle(.tertiary)
                        Text(String(repeating: "$", count: priceRange))
                    }
                }
                
                Spacer()
            }
            .font(.custom(style: .headline))
            .padding(.top)
            .padding(.vertical, 8)
            .redacted(reason: place == nil || isLoading ? .placeholder : [])
            .onTapGesture {
                if let mapActivity {
                    dismiss()
                    appData.mapNavStack.append(MapStack.place(id: mapActivity.id))
                }
            }
            
            Group {
                if let place, let thumbnail = place.thumbnail, !thumbnail.isEmpty, let url = URL(string: thumbnail) {
                    KFImage.url(url)
                        .placeholder {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(maxWidth: .infinity)
                                .frame(height: 140)
                                .foregroundStyle(Color.themePrimary.opacity(0.4))
                                .overlay {
                                    ProgressView()
                                }
                        }
                        .loadDiskFileSynchronously()
                        .cacheMemoryOnly()
                        .fade(duration: 0.25)
                        .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .contentShape(RoundedRectangle(cornerRadius: 15))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .foregroundStyle(Color.themePrimary.opacity(0.4))
                        .overlay {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Thumbnail not available")
                            }
                        }
                }
            }
            .onTapGesture {
                if let mapActivity {
                    dismiss()
                    appData.mapNavStack.append(MapStack.place(id: mapActivity.id))
                }
            }
            
            Divider()
            
            if mapActivity != nil {
                VStack {
                    if let checkins, checkins.count > 0 {
                        HStack {
                            Text("Checked In By")
                                .frame(width: 125, alignment: .leading)
                            
                            HStack(spacing: -10) {
                                ForEach(checkins.indices, id: \.self) { index in
                                    ProfileImage(checkins[index].profileImage, size: 30)
                                        .overlay(alignment: .bottomLeading) {
                                            if checkins[index].checkinsCount > 1 {
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 15, height: 15)
                                                        .foregroundStyle(Color.black)
                                                    
                                                    Text("\(checkins[index].checkinsCount)")
                                                        .font(.custom(style: .caption2))
                                                        .foregroundStyle(Color.white)
                                                }
                                                .frame(width: 15, height: 15)
                                            }
                                        }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    
                    if let reviews, reviews.count > 0 {
                        HStack {
                            Text("Reviewed By")
                                .frame(width: 125, alignment: .leading)
                            
                            HStack(spacing: -10) {
                                ForEach(reviews.indices, id: \.self) { index in
                                    ProfileImage(reviews[index].profileImage, size: 30)
                                        .overlay(alignment: .bottomLeading) {
                                            if reviews[index].reviewsCount > 1 {
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 15, height: 15)
                                                        .foregroundStyle(Color.black)
                                                    
                                                    Text("\(reviews[index].reviewsCount)")
                                                        .font(.custom(style: .caption2))
                                                        .foregroundStyle(Color.white)
                                                }
                                                .frame(width: 15, height: 15)
                                            }
                                        }
                                }
                                
                                Spacer()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .font(.custom(style: .body))
        .onAppear {
            if let mapActivity {
                Task {
                    await getPlace(id: mapActivity.id)
                }
            }
        }
    }
}

#Preview {
    MapActivityView(mapActivity: .constant(nil))
}
