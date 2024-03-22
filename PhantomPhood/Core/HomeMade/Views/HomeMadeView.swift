//
//  HomeMadeView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/12/24.
//

import SwiftUI
import PhotosUI

struct HomeMadeView: View {
    @StateObject private var vm = HomeMadeVM()
    @StateObject private var pickerVM = PickerVM()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.loadingSections.contains(.submitting) {
                VStack {
                    Spacer()
                    
                    LottieView(file: .processing, loop: true)
                        .frame(width: UIScreen.main.bounds.width * 0.65, height: UIScreen.main.bounds.width * 0.65)
                    
                    VStack(spacing: 20) {
                        Text("**In progress:**\nCompressing and uploading your content.\nNot live yet – stay tuned!")
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
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        if pickerVM.mediaItems.isEmpty {
                            Image(.homemade)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 150)
                                .padding(.vertical, 20)
                        } else {
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
                                                }
                                            case .failure(let error):
                                                Text("Error: \(error.localizedDescription)")
                                                    .frame(width: 110, height: 140)
                                            }
                                        }
                                        .frame(width: 110)
                                    }
                                }
                                .frame(height: 190)
                                .font(.custom(style: .subheadline))
                                .padding(.horizontal)
                            }
                            .scrollIndicators(.never)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Add Images/Videos of Your Homemade Food&Drinks")
                                .font(.custom(style: .headline))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        CTAButton {
                            vm.presentedSheet = .photosPicker
                        } label: {
                            Label {
                                Text(pickerVM.selection.isEmpty ? "Add Images/Videos" : "Edit Images/Videos")
                                    .fontWeight(.medium)
                            } icon: {
                                Image(systemName: "camera.fill")
                            }
                        }
                        .padding(.horizontal)
                        .disabled(vm.loadingSections.contains(.submitting))
                        .photosPicker(isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: HomeMadeVM.Sheets.photosPicker), selection: $pickerVM.selection, maxSelectionCount: 10, matching: .any(of: [.images, .videos]), photoLibrary: .shared())
                        
                        Divider()
                        
                        TextField("(Optional) - Caption", text: $vm.content, axis: .vertical)
                            .lineLimit(6...20)
                            .disabled(vm.loadingSections.contains(.submitting))
                            .padding(.all, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.themePrimary)
                            }
                            .padding(.horizontal)
                        
                        Divider()
                        
                        VStack {
                            if vm.tags.isEmpty {
                                Text("Tag People (Find your fellow friends on the app and tag them!)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.custom(style: .caption))
                                    .foregroundStyle(Color.secondary)
                                    .padding(.bottom, 8)
                            } else {
                                ForEach(vm.tags) { user in
                                    MentionItem(vm: vm, user: user)
                                }
                            }
                            
                            Button {
                                withAnimation {
                                    vm.presentedSheet = .userSelector
                                }
                            } label: {
                                HStack {
                                    Circle()
                                        .foregroundStyle(Color.themePrimary)
                                        .frame(width: 28, height: 28)
                                        .overlay {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Color.accentColor)
                                        }
                                    Text("Tag People")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .disabled(vm.loadingSections.contains(.submitting))
                            .foregroundStyle(Color.accentColor)
                            .sheet(isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: HomeMadeVM.Sheets.userSelector)) {
                                if #available(iOS 16.4, *) {
                                    UserSelector { user in
                                        if !vm.tags.contains(where: { $0.id == user.id }) {
                                            vm.tags.append(user)
                                        }
                                    }
                                    .presentationBackground(.thinMaterial)
                                } else {
                                    UserSelector { user in
                                        if !vm.tags.contains(where: { $0.id == user.id }) {
                                            vm.tags.append(user)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            
            VStack {
                Divider()
                
                CTAButton {
                    Task {
                        await vm.submit(mediaItems: pickerVM.mediaItems)
                    }
                } label: {
                    HStack {
                        if vm.loadingSections.contains(.submitting) {
                            ProgressView()
                                .controlSize(.regular)
                                .padding(.trailing, 3)
                                .transition(AnyTransition.opacity)
                        }
                        
                        Text("Submit".uppercased())
                    }
                }
                .disabled(vm.loadingSections.contains(.submitting))
                .padding(.horizontal)
            }
        }
        .onChange(of: vm.finished) { value in
            if value {
                dismiss()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle("Homemade Experience")
        .navigationBarTitleDisplayMode(.inline)
    }
}

fileprivate struct MentionItem: View {
    @ObservedObject var vm: HomeMadeVM
    let user: UserEssentials
    
    var body: some View {
        HStack {
            ProfileImage(user.profileImage, size: 28)
            
            Text(user.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                withAnimation {
                    vm.tags.removeAll(where: { $0.id == user.id })
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(Color.red)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeMadeView()
    }
    .font(.custom(style: .body))
}
