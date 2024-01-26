//
//  AddReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/8/23.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct AddReviewView: View {
    @ObservedObject var appData = AppData.shared
    @StateObject var vm: AddReviewVM
    
    init(_ idOrData: IdOrData<PlaceEssentials>) {
        self._vm = StateObject(wrappedValue: AddReviewVM(idOrData: idOrData))
    }
    
    init(mapPlace: MapPlace) {
        self._vm = StateObject(wrappedValue: AddReviewVM(mapPlace: mapPlace))
    }
    
    @Environment(\.dismiss) var dismiss
    
    let overallScoreEmojis = ["☹️", "😕", "🙂", "😊", "😊"]
    let foodQualityEmojis = ["🤮", "😕", "🙂", "😋", "🤤"]
    let drinkQualityEmojis = ["🤮", "😕", "🙂", "😋", "🤤"]
    let serviceEmojis = ["😠", "😪", "🙂", "👌", "💖"]
    let atmosphereEmojis = ["😖", "😕", "🙂", "😉", "🤩"]
    
    @StateObject private var pickerVM = PickerVM()
    
    @FocusState var textFieldFocused
    
    var body: some View {
        ZStack {
            if let place = vm.place {
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            if let thumbnail = place.thumbnail, let url = URL(string: thumbnail) {
                                KFImage.url(url)
                                    .placeholder {
                                        RoundedRectangle(cornerRadius: 10)
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
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            VStack(spacing: 10) {
                                Text(place.name)
                                    .font(.custom(style: .body))
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(place.location.address ?? "-")
                                    .font(.custom(style: .caption))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Divider()
                    }
                    .background(.ultraThinMaterial)
                    
                    switch vm.step {
                    case .recommendation:
                        VStack {
                            Text("Do you recommend this place?")
                                .font(.custom(style: .headline))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                            
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation {
                                        if vm.isRecommended == false {
                                            vm.isRecommended = nil
                                        } else {
                                            vm.isRecommended = false
                                            vm.step = .scores
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
                                            vm.step = .scores
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
                                                        if vm.haveAllScores {
                                                            vm.step = .review
                                                        }
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
                                                        if vm.haveAllScores {
                                                            vm.step = .review
                                                        }
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
                                                        if vm.haveAllScores {
                                                            vm.step = .review
                                                        }
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
                                                        if vm.haveAllScores {
                                                            vm.step = .review
                                                        }
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
                                                        if vm.haveAllScores {
                                                            vm.step = .review
                                                        }
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
                            .padding(.top)
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
                            .padding(.top)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(pickerVM.mediaItems) { item in
                                        switch item.state {
                                        case .empty:
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
                                        case .loaded(let mediaData):
                                            switch mediaData {
                                            case .image(let uiImage):
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 110, height: 140)
                                                    .clipShape(.rect(cornerRadius: 10))
                                            case .movie(let url):
                                                ReviewVideoView(url: url, mute: true)
                                                    .frame(width: 110, height: 140)
                                                    .clipShape(.rect(cornerRadius: 10))
                                            }
                                        case .failure(let error):
                                            Text("Error: \(error.localizedDescription)")
                                                .frame(width: 110, height: 140)
                                        }
                                    }
                                }
                                .font(.custom(style: .subheadline))
                                .padding(.horizontal)
                            }
                            .scrollIndicators(.never)
                            
                            PhotosPicker(
                                selection: $pickerVM.selection,
                                matching: .any(of: [.images, .videos]),
                                photoLibrary: .shared()
                            ) {
                                Label {
                                    Text(pickerVM.selection.isEmpty ? "Add Images/Videos" : "Edit Images/Videos")
                                } icon: {
                                    Image(systemName: "photo.on.rectangle.fill")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .disabled(vm.isSubmitting)
                            .buttonStyle(.bordered)
                            .padding(.horizontal)
                        }
                        .scrollDismissesKeyboard(.interactively)
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
                                if pickerVM.isReadyToSubmit {
                                    Task {
                                        await vm.submit(mediaItems: pickerVM.mediaItems)
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
                            .disabled(vm.isSubmitting || !pickerVM.isReadyToSubmit)
                        }
                    }
                    .font(.custom(style: .body))
                    .padding()
                }
            } else if let error = vm.error {
                Text(error)
            }
            
            if vm.isSubmitting {
                VStack {
                    Spacer()
                    
                    LottieView(file: .processing, loop: true)
                        .frame(width: UIScreen.main.bounds.width * 0.65, height: UIScreen.main.bounds.width * 0.65)
                    
                    VStack(spacing: 20) {
                        Text("**Review in progress:**\nCompressing and uploading your content.\nNot live yet – stay tuned!")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                        
                        Text("Almost there! This may take a minute or two.\n🚀 Feel free to explore the app. No need to wait here!")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .italic()
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("👍")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.vertical)
                    
                    Spacer()
                }
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                .font(.custom(style: .body))
                .padding(.horizontal)
                .background(Color.themeBG.ignoresSafeArea())
            }
        }
        .navigationTitle("Add Review")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: !vm.isSubmitting && vm.place == nil && vm.error == nil ) { value in
            if value {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddReviewView(.id("TestId"))
    }
}
