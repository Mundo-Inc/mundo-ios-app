//
//  QuickActionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/5/24.
//

import SwiftUI

struct QuickActionsView: View {
    @ObservedObject var placeSelectorVM = PlaceSelectorVM.shared
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var appData = AppData.shared
    
    @ObservedObject private var toastViewModel = ToastVM.shared
    var placeDM = PlaceDM()
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 30, height: 3)
                .padding(.top)
                .foregroundStyle(.tertiary)
            
            Spacer()
            
            if let placeId = appData.visiblePlaceId() {
                Button {
                    appData.goTo(AppRoute.checkin(.id(placeId)))
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.diamond")
                            .font(.system(size: 28))
                            .frame(width: 36 , height: 36)
                        
                        VStack {
                            Text("Check-in")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Check in to here")
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
                
                Button {
                    appData.goTo(AppRoute.review(.id(placeId)))
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "star.bubble")
                            .font(.system(size: 28))
                            .frame(width: 36 , height: 36)
                        
                        VStack {
                            Text("Review")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Add a review to to this place")
                                .font(.custom(style: .caption))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
            } else {
                Button {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        placeSelectorVM.present { mapItem in
                            if let name = mapItem.name {
                                appData.goTo(AppRoute.checkinMapPlace(MapPlace(coordinate: mapItem.placemark.coordinate, title: name)))
                            }
                        }
                    }
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.diamond")
                            .font(.system(size: 28))
                            .frame(width: 36 , height: 36)
                        
                        VStack {
                            Text("Check-in")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Check in to places that you go!")
                                .multilineTextAlignment(.leading)
                                .font(.custom(style: .caption))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
                
                Button {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        placeSelectorVM.present { mapItem in
                            if let name = mapItem.name {
                                appData.goTo(AppRoute.reviewMapPlace(MapPlace(coordinate: mapItem.placemark.coordinate, title: name)))
                            }
                        }
                    }
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "star.bubble")
                            .font(.system(size: 28))
                            .frame(width: 36 , height: 36)
                        
                        VStack {
                            Text("Review")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Add a review to a place that you’ve been")
                                .font(.custom(style: .caption))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.themePrimary)
                    .clipShape(.rect(cornerRadius: 15))
                }
                .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .presentationDetents([.height(250)])
    }
}

#Preview {
    QuickActionsView()
}
