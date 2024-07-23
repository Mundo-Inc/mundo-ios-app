//
//  QuickActionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/5/24.
//

import SwiftUI

struct QuickActionsView: View {
    @StateObject private var vm = QuickActionsVM()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.mainWindowSafeAreaInsets) private var mainWindowSafeAreaInsets
    
    @State private var height: CGFloat = 500
    
    var body: some View {
        VStack(spacing: 20) {
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
                    .cfont(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
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
                            .cfont(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Group {
                            if let nearestPlace = vm.nearestPlace, let name = nearestPlace.name, vm.isNearestPlace {
                                Text("Check in to \(name)")
                            } else {
                                Text("Check in to places that you go!")
                            }
                        }
                        .multilineTextAlignment(.leading)
                        .cfont(.caption)
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
                            .cfont(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Group {
                            if let nearestPlace = vm.nearestPlace, let name = nearestPlace.name, vm.isNearestPlace {
                                Text("Add a review to \(name)")
                            } else {
                                Text("Add a review to a place that you’ve been")
                            }
                        }
                        .cfont(.caption)
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
        .background {
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.size) { newValue in
                        self.height = newValue.height + mainWindowSafeAreaInsets.bottom
                    }
            }
        }
        .cfont(.body)
        .padding()
        .presentationDetents([.height(height), .fraction(0.8)])
        .task {
            await vm.updateNearestPlace()
        }
    }
}

#Preview {
    QuickActionsView()
}
