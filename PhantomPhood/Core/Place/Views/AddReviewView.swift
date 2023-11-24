//
//  AddReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/8/23.
//

import SwiftUI
import PhotosUI
import AVKit
import Kingfisher

struct AddReviewView: View {
    @ObservedObject var placeVM: PlaceViewModel
    
    @Environment(\.dismiss) var dismiss
    
    let overallScoreEmojis = ["☹️", "😕", "🙂", "😊", "😊"]
    let foodQualityEmojis = ["🤮", "😕", "🙂", "😋", "🤤"]
    let drinkQualityEmojis = ["🤮", "😕", "🙂", "😋", "🤤"]
    let serviceEmojis = ["😠", "😪", "🙂", "👌", "💖"]
    let atmosphereEmojis = ["😖", "😕", "🙂", "😉", "🤩"]
    
    @StateObject private var vm = AddReviewViewModel()
    @FocusState var textFieldFocused
    
    var body: some View {
        ZStack {
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
                            KFImage.url(url)
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 10)
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
                                .disabled(vm.isSubmitting)
                                .toggleStyle(SwitchToggleStyle())
                                
                                TextField("Tell us more...", text: $vm.reviewContent, axis: .vertical)
                                    .lineLimit(6...20)
                                    .focused($textFieldFocused)
                                    .disabled(vm.isSubmitting)
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
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 110, height: 140)
                                                    .clipShape(.rect(cornerRadius: 10))
                                            } else {
                                                ZStack {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 110, height: 140)
                                                        .clipShape(.rect(cornerRadius: 10))
                                                        .onAppear {
                                                            vm.compress(item: item)
                                                        }
                                                    
                                                    VStack {
                                                        Text("Resizing")
                                                            .font(.custom(style: .caption))
                                                        ProgressView()
                                                    }
                                                }
                                                .frame(width: 110, height: 140)
                                            }
                                        case .successMovie(let movie):
                                            VStack {
                                                if item.isCompressed {
                                                    ReviewVideoView(url: movie.url, mute: true)
                                                        .frame(width: 110, height: 140)
                                                        .clipShape(.rect(cornerRadius: 10))
                                                } else {
                                                    ZStack {
                                                        ReviewVideoView(url: movie.url, mute: true)
                                                            .frame(width: 110, height: 140)
                                                            .clipShape(.rect(cornerRadius: 10))
                                                            .onAppear {
                                                                vm.compress(item: item)
                                                            }
                                                        
                                                        Color.black.opacity(0.5)
                                                        
                                                        VStack {
                                                            Text("Resizing")
                                                                .font(.custom(style: .caption))
                                                            ProgressView()
                                                        }
                                                    }
                                                    .clipShape(.rect(cornerRadius: 10))
                                                }
                                            }
                                            .frame(width: 110, height: 140)
                                        case .loading:
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundStyle(Color.themePrimary)
                                                .frame(width: 110, height: 140)
                                                .overlay {
                                                    VStack {
                                                        Text("Loading")
                                                            .font(.custom(style: .caption))
                                                        ProgressView()
                                                    }
                                                }
                                        default:
                                            Text("Error")
                                                .frame(width: 110, height: 140)
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
                            .disabled(vm.isSubmitting)
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
                            .opacity(vm.isSubmitting ? 0.6 : 1)
                            .disabled(vm.isSubmitting)
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
                                if let place = placeVM.place {
                                    Task {
                                        await vm.submit(place: place.id)
                                        dismiss()
                                    }
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    if vm.isSubmitting {
                                        ProgressView()
                                    }
                                    Text(vm.isSubmitting ? "Submitting" : "Submit")
                                }
                                .padding(.horizontal)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isSubmitting || vm.mediaItemsState.reduce(false, { accumulator, item in
                                if !item.isCompressed {
                                    return true
                                } else {
                                    return accumulator
                                }
                            }))
                        }
                    }
                    .font(.custom(style: .body))
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            } else {
                EmptyView()
            }
            
            if vm.isSubmitting {
                Color.black.opacity(0.7)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView(
                            "Submitting...",
                            value: vm.mediaItemsState.count >= 1 ? max(
                                Double((vm.imageUploads.count + vm.videoUploads.count) / vm.mediaItemsState.count),
                                0.2
                            ) : 0.9
                        )
                        .animation(.bouncy, value: vm.mediaItemsState.count >= 1 ? max(Double((vm.imageUploads.count + vm.videoUploads.count) / vm.mediaItemsState.count), 0.2) : 0.9)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddReviewView(placeVM: PlaceViewModel(id: "645c1d1ab41f8e12a0d166bc"))
    }
}
