//
//  EditProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 17.09.2023.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var auth = Authentication.shared
    
    @StateObject private var vm = EditProfileVM()
    @StateObject private var pickerVM = PickerVM(limitToOne: true)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Profile Picture")
                        .cfont(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Button {
                                vm.presentedSheet = .photosPicker
                            } label: {
                                if let mediaItem = pickerVM.mediaItems.first {
                                    switch mediaItem.state {
                                    case .empty, .loading(_):
                                        RoundedRectangle(cornerRadius: 15)
                                            .frame(width: 90, height: 90)
                                            .foregroundStyle(.tertiary)
                                            .overlay {
                                                ProgressView()
                                            }
                                    case .failure(_):
                                        self.profileImage(image: Image(systemName: "exclamationmark.triangle.fill"))
                                            .overlay {
                                                Color.black.opacity(0.5)
                                                
                                                if !vm.isDeleting {
                                                    Image(systemName: "square.and.pencil")
                                                        .font(.system(size: 36))
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                    case .loaded(let mediaData):
                                        if case .image(let uiImage) = mediaData {
                                            self.profileImage(image: Image(uiImage: uiImage))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .foregroundStyle(Color.black.opacity(0.5))
                                                    
                                                    if !vm.isDeleting {
                                                        Image(systemName: "square.and.pencil")
                                                            .font(.system(size: 36))
                                                            .symbolRenderingMode(.hierarchical)
                                                            .foregroundStyle(.white)
                                                    }
                                                }
                                        }
                                    }
                                } else if let profileImage = auth.currentUser?.profileImage {
                                    ImageLoader(profileImage, contentMode: .fill) { _ in
                                        Image(systemName: "arrow.down.circle.dotted")
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(width: 90, height: 90)
                                    .background(Color.themePrimary, in: .rect(cornerRadius: 15))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundStyle(Color.black.opacity(0.5))
                                        
                                        if !vm.isDeleting {
                                            Image(systemName: "square.and.pencil")
                                                .font(.system(size: 36))
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(.white)
                                        }
                                        
                                    }
                                    .clipShape(.rect(cornerRadius: 15))
                                } else {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(Color.themePrimary)
                                        .frame(width: 90, height: 90)
                                        .overlay {
                                            Image(systemName: "photo.badge.plus.fill")
                                                .font(.system(size: 36))
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(.primary)
                                        }
                                }
                            }
                            .foregroundStyle(.primary)
                            
                            if let user = auth.currentUser {
                                Text(user.profileImage == nil ? "Add" : vm.isDeleting ? "Removing" : "Edit")
                                    .cfont(.caption)
                                    .foregroundStyle(Color.accentColor)
                                
                            }
                        }
                        .scaleEffect(vm.isDeleting ? 0.8 : 1)
                        .offset(x: vm.isDeleting ? 10 : 0)
                        
                        if let user = auth.currentUser, user.profileImage != nil {
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    vm.isDeleting.toggle()
                                }
                            } label: {
                                VStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .inset(by: 2)
                                        .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 2, dash: [8]))
                                        .frame(width: 90, height: 90)
                                        .overlay {
                                            Image(systemName: vm.isDeleting ? "arrow.counterclockwise.circle.fill" : "trash.circle")
                                                .font(.system(size: 36))
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(vm.isDeleting ? Color.accentColor : .secondary)
                                        }
                                    
                                    Text(vm.isDeleting ? "Undo" : "Remove")
                                        .cfont(.caption)
                                        .foregroundStyle(vm.isDeleting ? Color.accentColor : .secondary)
                                }
                                .scaleEffect(vm.isDeleting ? 1.2 : 1)
                                .offset(x: vm.isDeleting ? -10 : 0)
                            }
                            .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    VStack {
                        HStack(alignment: .top) {
                            Text("Name")
                                .cfont(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 90, height: 42, alignment: .leading)
                            
                            TextField("Name", text: $vm.name)
                                .frame(height: 42)
                                .background(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.tertiary)
                                }
                        }
                        HStack(alignment: .top) {
                            Text("Username")
                                .cfont(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 90, height: 42, alignment: .leading)
                            
                            TextField("Username", text: $vm.username)
                                .keyboardType(.default)
                                .autocorrectionDisabled(true)
                                .frame(height: 42)
                                .background(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.tertiary)
                                }
                                .overlay(alignment: .trailing) {
                                    HStack {
                                        if !vm.username.isEmpty {
                                            if vm.loadingSections.contains(.checkingUsername) {
                                                ProgressView()
                                            } else if vm.isUsernameValid {
                                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                            } else {
                                                Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .allowsTightening(false)
                                }
                        }
                        
                        HStack(alignment: .top) {
                            Text("Bio")
                                .cfont(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 90, height: 42, alignment: .leading)
                            
                            TextField("Bio", text: $vm.bio, axis: .vertical)
                                .lineLimit(5...8)
                                .overlay {
                                    if vm.bio.count > 0 {
                                        Text("\(vm.bio.count)/250")
                                            .cfont(.caption)
                                            .foregroundStyle(vm.bio.count > 250 ? Color.red : Color.secondary)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                    }
                                }
                                .padding(.vertical, 10)
                                .background(alignment: .bottom) {
                                    Rectangle()
                                        .frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                        .foregroundStyle(.tertiary)
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                guard let user = auth.currentUser else { return }
                
                vm.name = user.name
                vm.username = user.username
                vm.bio = user.bio ?? ""
            }
            .photosPicker(
                isPresented: Binding(optionalValue: $vm.presentedSheet, ofCase: EditProfileVM.Sheets.photosPicker),
                selection: $pickerVM.selection,
                maxSelectionCount: 1,
                matching: .any(of: [.images]),
                photoLibrary: .shared()
            )
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Edit Profile Info")
            .toolbar {
                let isSubmitting = vm.loadingSections.contains(.submittingChanges)
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .cfont(.headline)
                    }
                    .disabled(isSubmitting)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await vm.save(image: pickerVM.mediaItems.first)
                            dismiss()
                        }
                    } label: {
                        ZStack {
                            Text("Save")
                                .cfont(.headline)
                                .opacity(isSubmitting ? 0 : 1)
                            
                            if isSubmitting {
                                ProgressView()
                            }
                        }
                        .animation(.none, value: isSubmitting)
                    }
                    .disabled(isSubmitting)
                }
            }
            .background(Color.themeBG.ignoresSafeArea())
        }
    }
}

extension EditProfileView {
    func profileImage(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 90, height: 90)
            .background(Color.themePrimary, in: .rect(cornerRadius: 15))
            .clipShape(.rect(cornerRadius: 15))
    }
}

#Preview {
    EditProfileView()
}
