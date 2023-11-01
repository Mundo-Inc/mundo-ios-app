//
//  PlaceMediaView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI
import Kingfisher

struct PlaceMediaView: View {
    @ObservedObject var vm: PlaceViewModel
    
    @StateObject var placeMediaViewModel: PlaceMediaViewModel
    
    init(placeId: String, vm: PlaceViewModel) {
        self.vm = vm
        self._placeMediaViewModel = StateObject(wrappedValue: PlaceMediaViewModel(placeId: placeId))
    }
    
    
    let gridColumnst: [GridItem] = [
        GridItem(.flexible(minimum: 100, maximum: 500), spacing: 10),
        GridItem(.flexible(minimum: 100, maximum: 500), spacing: 10)
    ]
    var body: some View {
        ScrollView {
            if !placeMediaViewModel.isLoading && placeMediaViewModel.medias.isEmpty {
                Text("No media")
                    .font(.custom(style: .subheadline))
                    .foregroundStyle(.secondary)
                    .padding(.vertical)
                    .padding(.horizontal)
            } else {
                LazyVGrid(columns: gridColumnst, content: {
                    ForEach(placeMediaViewModel.medias) {media in
                        if let url = URL(string: media.src) {
                            KFImage.url(url)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(Color.themePrimary)
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
                                .frame(width: (UIScreen.main.bounds.size.width / 2) - 30, height: UIScreen.main.bounds.size.width / 2)
                                .contentShape(Rectangle())
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    Color.clear
                        .onAppear {
                            Task {
                                await placeMediaViewModel.fetch(type: .new)
                            }
                        }
                })
                .clipped()
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    PlaceMediaView(placeId: "645c1d1ab41f8e12a0d166bc", vm: PlaceViewModel(id: "645c1d1ab41f8e12a0d166bc"))
}
