//
//  AddReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/8/23.
//

import SwiftUI
import PhotosUI
import AVKit

struct AddReviewView: View {
    @ObservedObject var placeVM: PlaceViewModel
    
    @Environment(\.dismiss) var dismiss
    
    let overallScoreEmojis = ["☹️", "😕", "🙂", "😊", "😊"]
    let foodQualityEmojis = ["🤮", "😕", "🙂", "😋", "🤤"]
    let drinkQualityEmojis = ["🤮", "😕", "🙂", "😋", "🤤"]
    let serviceEmojis = ["😠", "😪", "🙂", "👌", "💖"]
    let atmosphereEmojis = ["😖", "😕", "🙂", "😉", "🤩"]
    
    @StateObject var vm = AddReviewViewModel()
    @FocusState var textFieldFocused
    
    var body: some View {
        if let place = placeVM.place {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    
                    Spacer()
                }
                .font(.custom(style: .body))
                .padding(.horizontal)
                
                HStack {
                    if let thumbnail = place.thumbnail, let url = URL(string: thumbnail) {
                        CacheAsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                RoundedRectangle(cornerRadius: 10)
                                    .overlay {
                                        ProgressView()
                                    }
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            default:
                                RoundedRectangle(cornerRadius: 10)
                                    .overlay {
                                        Image(systemName: "photo")
                                    }
                            }
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    VStack {
                        Text(place.name)
                            .font(.custom(style: .body))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)

                        
                        Text(place.location.address ?? (place.scores.overall != nil ? String(place.scores.overall!) : "-"))
                            .font(.custom(style: .caption))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)

                Divider()
                                
                switch vm.step {
                case .recommendation:
                    VStack {
                        Text("Do you recommend this place?")
                            .font(.custom(style: .headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    if vm.isRecommended == false {
                                        vm.isRecommended = nil
                                    } else {
                                        vm.isRecommended = false
                                    }
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(vm.isRecommended == false ? Color.accentColor : Color.themePrimary)
                                    .overlay {
                                        Text("👎")
                                    }
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    if vm.isRecommended == true {
                                        vm.isRecommended = nil
                                    } else {
                                        vm.isRecommended = true
                                    }
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(vm.isRecommended == true ? Color.accentColor : Color.themePrimary)
                                    .overlay {
                                        Text("👍")
                                    }
                            }
                            Spacer()
                        }
                        .padding(.top)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal)
                case .scores:
                    ScrollView {
                        VStack {
                            Section {
                                HStack {
                                    ForEach(overallScoreEmojis.indices, id: \.self) { index in
                                        Button {
                                            withAnimation {
                                                if vm.overallScore == index + 1 {
                                                    vm.overallScore = nil
                                                } else {
                                                    vm.overallScore = index + 1
                                                }
                                            }
                                        } label: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 50, height: 50)
                                                .frame(maxWidth: .infinity)
                                                .foregroundStyle(vm.overallScore == index + 1 ? Color.accentColor : Color.themePrimary)
                                                .overlay {
                                                    Text(overallScoreEmojis[index])
                                                }
                                        }
                                    }
                                }
                            } header: {
                                Text("Overall Score")
                                    .font(.custom(style: .headline))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                                                        
                            Section {
                                HStack {
                                    ForEach(foodQualityEmojis.indices, id: \.self) { index in
                                        Button {
                                            withAnimation {
                                                if vm.foodQuality == index + 1 {
                                                    vm.foodQuality = nil
                                                } else {
                                                    vm.foodQuality = index + 1
                                                }
                                            }
                                        } label: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 50, height: 50)
                                                .frame(maxWidth: .infinity)
                                                .foregroundStyle(vm.foodQuality == index + 1 ? Color.accentColor : Color.themePrimary)
                                                .overlay {
                                                    Text(foodQualityEmojis[index])
                                                }
                                        }
                                    }
                                }
                            } header: {
                                Text("Food Quality")
                                    .font(.custom(style: .headline))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Section {
                                HStack {
                                    ForEach(drinkQualityEmojis.indices, id: \.self) { index in
                                        Button {
                                            withAnimation {
                                                if vm.drinkQuality == index + 1 {
                                                    vm.drinkQuality = nil
                                                } else {
                                                    vm.drinkQuality = index + 1
                                                }
                                            }
                                        } label: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 50, height: 50)
                                                .frame(maxWidth: .infinity)
                                                .foregroundStyle(vm.drinkQuality == index + 1 ? Color.accentColor : Color.themePrimary)
                                                .overlay {
                                                    Text(drinkQualityEmojis[index])
                                                }
                                        }
                                    }
                                }
                            } header: {
                                Text("Drink Quality")
                                    .font(.custom(style: .headline))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Section {
                                HStack {
                                    ForEach(serviceEmojis.indices, id: \.self) { index in
                                        Button {
                                            withAnimation {
                                                if vm.service == index + 1 {
                                                    vm.service = nil
                                                } else {
                                                    vm.service = index + 1
                                                }
                                            }
                                        } label: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 50, height: 50)
                                                .frame(maxWidth: .infinity)
                                                .foregroundStyle(vm.service == index + 1 ? Color.accentColor : Color.themePrimary)
                                                .overlay {
                                                    Text(serviceEmojis[index])
                                                }
                                        }
                                    }
                                }
                            } header: {
                                Text("Service")
                                    .font(.custom(style: .headline))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Section {
                                HStack {
                                    ForEach(atmosphereEmojis.indices, id: \.self) { index in
                                        Button {
                                            withAnimation {
                                                if vm.atmosphere == index + 1 {
                                                    vm.atmosphere = nil
                                                } else {
                                                    vm.atmosphere = index + 1
                                                }
                                            }
                                        } label: {
                                            RoundedRectangle(cornerRadius: 8)
                                                .frame(width: 50, height: 50)
                                                .frame(maxWidth: .infinity)
                                                .foregroundStyle(vm.atmosphere == index + 1 ? Color.accentColor : Color.themePrimary)
                                                .overlay {
                                                    Text(atmosphereEmojis[index])
                                                }
                                        }
                                    }
                                }
                            } header: {
                                Text("Atmosphere")
                                    .font(.custom(style: .headline))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    }
                case .review:
                    ScrollView {
                        VStack(spacing: 20) {
                            Toggle(isOn: $vm.isPublic) {
                                Text("Share my review with others")
                            }
                            .toggleStyle(SwitchToggleStyle())
                            
                            TextField("Tell us more...", text: $vm.reviewContent, axis: .vertical)
                                .lineLimit(6...20)
                                .focused($textFieldFocused)
                                .padding(.all, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(Color.themePrimary)
                                }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(vm.mediaItemsState) { item in
                                    switch item.state {
                                    case .successImage(let image):
                                        if item.isCompressed {
                                            Text("Compressed")
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 140)
                                                .clipShape(.rect(cornerRadius: 10))
                                        } else {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 140)
                                                .clipShape(.rect(cornerRadius: 10))
                                                .onAppear {
                                                    vm.compress(item: item)
                                                }
                                        }
                                        
                                    case .successMovie(let movie):
                                        VStack {
                                            if item.isCompressed {
                                                VideoPlayer(player: AVPlayer(url: movie.url))
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(.rect(cornerRadius: 10))
                                            } else {
                                                VideoPlayer(player: AVPlayer(url: movie.url))
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(.rect(cornerRadius: 10))
                                                    .onAppear {
                                                        vm.compress(item: item)
                                                    }
                                            }
                                        }
                                    case .loading:
                                        ProgressView()
                                    default:
                                        Text("Error ")
                                    }
                                }
                            }
                            .font(.custom(style: .subheadline))
                            .padding(.horizontal)
                        }
                        
                        PhotosPicker(
                            selection: $vm.mediaSelection,
                            matching: .any(of: [.images, .videos]),
                            photoLibrary: .shared()
                        ) {
                            Label {
                                Text(vm.mediaSelection.isEmpty ? "Add Images/Videos" : "Edit Images/Videos")
                            } icon: {
                                Image(systemName: "photo.on.rectangle.fill")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.horizontal)

                    }
                    .scrollDismissesKeyboard(.immediately)
                }
                
                HStack {
                    if vm.step != .recommendation {
                        Button {
                            switch vm.step {
                            case .scores:
                                withAnimation {
                                    vm.step = .recommendation
                                }
                            case .review:
                                withAnimation {
                                    vm.step = .scores
                                }
                            default:
                                break
                            }
                        } label: {
                            Text("Previous")
                        }
                    }
                    
                    Spacer()
                    
                    switch vm.step {
                    case .recommendation:
                        Button {
                            withAnimation {
                                vm.step = .scores
                            }
                        } label: {
                            Text(vm.isRecommended != nil ? "Next" : "Skip")
                                .padding(.horizontal)
                        }
                        .buttonStyle(.bordered)
                    case .scores:
                        Button {
                            withAnimation {
                                vm.step = .review
                                textFieldFocused = true
                            }
                        } label: {
                            Text(vm.haveAnyScore ? "Next" : "Skip")
                                .padding(.horizontal)
                        }
                        .buttonStyle(.bordered)
                    case .review:
                        Button {
                            print("Submit")
                        } label: {
                            Text("Submit")
                                .padding(.horizontal)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .font(.custom(style: .body))
                .padding(.horizontal)
                .padding(.bottom)
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        AddReviewView(placeVM: PlaceViewModel(id: "645c1d1ab41f8e12a0d166bc"))
    }
}
