//
//  AddReviewView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/8/23.
//

import SwiftUI
import PhotosUI

struct AddReviewView: View {
    @ObservedObject private var appData = AppData.shared
    @StateObject private var vm: AddReviewVM
    
    init(_ idOrData: IdOrData<PlaceEssentials>) {
        self._vm = StateObject(wrappedValue: AddReviewVM(idOrData: idOrData))
    }
    
    init(mapPlace: MapPlace) {
        self._vm = StateObject(wrappedValue: AddReviewVM(mapPlace: mapPlace))
    }
    
    @Environment(\.dismiss) private var dismiss
    
    let overallScoreEmojis = ["☹️", "😕", "🙂", "😊", "😊"]
    let foodQualityEmojis = ["🤮", "😕", "🙂", "😋", "🤤"]
    let drinkQualityEmojis = ["🤮", "😕", "🙂", "😋", "🤤"]
    let serviceEmojis = ["😠", "😪", "🙂", "👌", "💖"]
    let atmosphereEmojis = ["😖", "😕", "🙂", "😉", "🤩"]
    
    @StateObject private var pickerVM = PickerVM()
    
    var body: some View {
        ZStack {
            if let place = vm.place {
                VStack(spacing: 0) {
                    VStack(spacing: 5) {
                        HStack {
                            ImageLoader(place.thumbnail, contentMode: .fill) { Progress in
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.themePrimary)
                                    .overlay {
                                        ProgressView()
                                    }
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(spacing: 10) {
                                Text(place.name)
                                    .font(.custom(style: .body))
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(place.location.address ?? "-")
                                    .lineLimit(1)
                                    .font(.custom(style: .caption))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        
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
                            .padding(.vertical)
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
                                    .disabled(vm.isSubmitting)
                                    .padding(.all, 10)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color.themePrimary)
                                    }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            Divider()
                            
                            PhotosPicker(
                                selection: $pickerVM.selection,
                                matching: .any(of: [.images, .videos]),
                                photoLibrary: .shared()
                            ) {
                                Label {
                                    Text(pickerVM.selection.isEmpty ? "Add Images/Videos" : "Edit Images/Videos")
                                        .fontWeight(.medium)
                                } icon: {
                                    Image(systemName: "camera.fill")
                                }
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(Color.themeBG)
                                .padding(.vertical, 12)
                                .background(Color.accentColor)
                                .clipShape(.rect(cornerRadius: 10))
                            }
                            .disabled(vm.isSubmitting)
                            .controlSize(.large)
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(pickerVM.mediaItems) { item in
                                        VStack(spacing: 10) {
                                            switch item.state {
                                            case .empty:
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundStyle(Color.themePrimary)
                                                    .frame(width: 110, height: 140)
                                                    .overlay {
                                                        Text("Loading")
                                                            .font(.custom(style: .caption))
                                                    }
                                                
                                                Circle()
                                                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                                    .frame(width: 28, height: 28)
                                                    .overlay {
                                                        ProgressView()
                                                    }
                                            case .loading:
                                                RoundedRectangle(cornerRadius: 10)
                                                    .foregroundStyle(Color.themePrimary)
                                                    .frame(width: 110, height: 140)
                                                    .overlay {
                                                        Text("Loading")
                                                            .font(.custom(style: .caption))
                                                    }
                                                
                                                Circle()
                                                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                                    .frame(width: 28, height: 28)
                                                    .overlay {
                                                        ProgressView()
                                                    }
                                            case .loaded(let mediaData):
                                                switch mediaData {
                                                case .image(let uiImage):
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 110, height: 140)
                                                        .clipShape(.rect(cornerRadius: 10))
                                                    
                                                    Button {
                                                        pickerVM.removeItem(item)
                                                    } label: {
                                                        Circle()
                                                            .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                                            .frame(width: 28, height: 28)
                                                            .overlay {
                                                                Image(systemName: "trash")
                                                                    .foregroundStyle(.red)
                                                            }
                                                    }
                                                    .contentShape(Circle())
                                                    .controlSize(.mini)
                                                case .movie(let url):
                                                    ReviewVideoView(url: url, mute: true)
                                                        .frame(width: 110, height: 140)
                                                        .clipShape(.rect(cornerRadius: 10))
                                                    
                                                    Button {
                                                        pickerVM.removeItem(item)
                                                    } label: {
                                                        Circle()
                                                            .stroke(Color.red.opacity(0.4), lineWidth: 1)
                                                            .frame(width: 28, height: 28)
                                                            .overlay {
                                                                Image(systemName: "trash")
                                                                    .foregroundStyle(.red)
                                                            }
                                                    }
                                                    .contentShape(Circle())
                                                    .controlSize(.mini)
                                                }
                                            case .failure(let error):
                                                Text("Error: \(error.localizedDescription)")
                                                    .frame(width: 110, height: 140)
                                            }
                                        }
                                    }
                                }
                                .font(.custom(style: .subheadline))
                                .padding(.horizontal)
                            }
                            .scrollIndicators(.never)
                            .padding(.bottom, 20)
                        }
                        .scrollDismissesKeyboard(.immediately)
                    }
                    
                    VStack {
                        Divider()
                        
                        HStack(spacing: 15) {
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
                                        .frame(maxWidth: .infinity)
                                }
                                .opacity(vm.isSubmitting ? 0.6 : 1)
                                .disabled(vm.isSubmitting)
                            }
                            
                            CTAButton {
                                switch vm.step {
                                case .recommendation:
                                    withAnimation {
                                        vm.step = .scores
                                    }
                                case .scores:
                                    withAnimation {
                                        vm.step = .review
                                    }
                                case .review:
                                    if pickerVM.isReadyToSubmit {
                                        Task {
                                            await vm.submit(mediaItems: pickerVM.mediaItems)
                                        }
                                    }
                                }
                            } label: {
                                switch vm.step {
                                case .recommendation:
                                    Text(vm.isRecommended != nil ? "Next" : "Skip")
                                case .scores:
                                    Text(vm.haveAnyScore ? "Next" : "Skip")
                                case .review:
                                    HStack(spacing: 8) {
                                        if vm.isSubmitting {
                                            ProgressView()
                                                .controlSize(.regular)
                                                .padding(.trailing, 3)
                                        }
                                        Text(vm.isSubmitting ? "Submitting" : "Submit")
                                    }
                                }
                            }
                            .disabled(vm.step == .review && (vm.isSubmitting || !pickerVM.isReadyToSubmit))
                        }
                        .padding(.horizontal)
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
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
