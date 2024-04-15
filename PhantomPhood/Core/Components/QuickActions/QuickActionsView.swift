//
//  QuickActionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/5/24.
//

import SwiftUI

struct QuickActionsView: View {
    @StateObject private var vm = QuickActionsVM()
    private let toastVM = ToastVM.shared
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 36, height: 5)
                .padding(.top, 5)
                .padding(.bottom)
                .foregroundStyle(.tertiary)
            
            if vm.loadingSections.contains(.nearestPlace) {
                ProgressView("Searching Area")
            } else if let nearestPlace = vm.nearestPlace, let name = nearestPlace.name, vm.isNearestPlace {
                HStack {
                    VStack {
                        Text("Are you here?")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Label {
                            Text(name)
                        } icon: {
                            Image(systemName: "mappin.and.ellipse")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button {
                        withAnimation {
                            vm.isNearestPlace = false
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.accentColor.opacity(0.1))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20))
                            }
                    }
                    
                }
            } else {
                Text("Choose Check-in or Review, then search to select your location.")
                    .foregroundStyle(.secondary)
                    .font(.custom(style: .caption))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            Button {
                vm.handleCheckin()
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
                        Group {
                            if let nearestPlace = vm.nearestPlace, let name = nearestPlace.name, vm.isNearestPlace {
                                Text("Check in to \(name)")
                            } else {
                                Text("Check in to places that you go!")
                            }
                        }
                        .multilineTextAlignment(.leading)
                        .font(.custom(style: .caption))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(Color.themePrimary)
                .clipShape(.rect(cornerRadius: 15))
            }
            .foregroundStyle(.primary)
            
            Button {
                vm.handleReview()
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
                        
                        Group {
                            if let nearestPlace = vm.nearestPlace, let name = nearestPlace.name, vm.isNearestPlace {
                                Text("Add a review to \(name)")
                            } else {
                                Text("Add a review to a place that you’ve been")
                            }
                        }
                        .font(.custom(style: .caption))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(Color.themePrimary)
                .clipShape(.rect(cornerRadius: 15))
            }
            .foregroundStyle(.primary)
            
            Button {
                AppData.shared.goTo(AppRoute.homemadeContent)
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "house.fill")
                        .font(.system(size: 28))
                        .frame(width: 36 , height: 36)
                    
                    VStack {
                        Text("Homemade Moments")
                            .font(.custom(style: .headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Group {
                            Text("Share your home cooking experience")
                        }
                        .font(.custom(style: .caption))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(Color.themePrimary)
                .clipShape(.rect(cornerRadius: 15))
            }
            .foregroundStyle(.primary)
        }
        .font(.custom(style: .body))
        .padding(.horizontal)
        .padding(.bottom)
        .presentationDetents([.height(340), .fraction(0.8)])
        .onAppear {
            Task {
                await vm.updateNearestPlace()
            }
        }
    }
}

#Preview {
    QuickActionsView()
}
