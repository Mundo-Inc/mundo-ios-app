//
//  QuickActionsView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/5/24.
//

import SwiftUI

struct QuickActionsView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var appData = AppData.shared
    
    @ObservedObject private var toastViewModel = ToastViewModel.shared
    @ObservedObject private var addReviewVM = AddReviewVM.shared
    var placeDM = PlaceDM()
    
    @State private var loading: LoadingSection? = nil
    
    func checkin(placeId: String) async {
        self.loading = .checkin
        do {
            try await placeDM.checkin(id: placeId)
            toastViewModel.toast(Toast(type: .success, title: "Checkin", message: "Checked in successfully"))
        } catch {
            print(error)
            toastViewModel.toast(Toast(type: .error, title: "Checkin", message: "Failed to checkin"))
        }
        self.loading = nil
    }
    
    enum LoadingSection {
        case checkin
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 30, height: 3)
                .padding(.top)
                .foregroundStyle(.tertiary)
            
            Spacer()
            
            if let placeId = appData.visiblePlaceId() {
                Button {
                    Task {
                        await checkin(placeId: placeId)
                        dismiss()
                    }
                } label: {
                    HStack {
                        if loading == .checkin {
                            ProgressView()
                                .frame(width: 36 , height: 36)
                        } else {
                            Image(systemName: "checkmark.diamond")
                                .font(.system(size: 28))
                                .frame(width: 36 , height: 36)
                        }
                        
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
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        addReviewVM.present(placeId: placeId)
                    }
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
                    searchViewModel.scope = .places
                    searchViewModel.tokens = [.checkin]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        searchViewModel.showSearch = true
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
                    searchViewModel.scope = .places
                    searchViewModel.tokens = [.addReview]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        searchViewModel.showSearch = true
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
    QuickActionsView(searchViewModel: SearchViewModel())
}
