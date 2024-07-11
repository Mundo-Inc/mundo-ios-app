//
//  EditProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 17.09.2023.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var auth = Authentication.shared
    @StateObject private var vm = EditProfileVM()
    
    var body: some View {
        ZStack {
            Color.themeBG.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(vm.isSubmitting)
                    
                    Spacer()
                    
                    Button {
                        Task {
                            do {
                                try await vm.save()
                                dismiss()
                            } catch {
                                presentErrorToast(error)
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            if vm.isSubmitting {
                                ProgressView()
                            }
                            Text("Save")
                                .cfont(.headline)
                        }
                        .animation(.none, value: vm.isSubmitting)
                    }
                    .disabled(vm.isSubmitting)
                    
                }.padding(.horizontal)
                
                Divider()
                
                ScrollView {
                    Text("Profile Picture")
                        .cfont(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Spacer()
                        VStack {
                            switch vm.imageState {
                            case .success(let (image, _, _)):
                                self.profileImage(image: image)
                                    .overlay {
                                        ZStack {
                                            Color.black.opacity(0.5)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                            PhotosPicker(
                                                selection: $vm.imageSelection,
                                                matching: .images,
                                                photoLibrary: .shared()
                                            ) {
                                                if !vm.isDeleting {
                                                    Image(systemName: "square.and.pencil")
                                                        .font(.system(size: 36))
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundStyle(.white)
                                                }
                                                
                                            }
                                        }
                                    }
                            case .empty:
                                if let user = auth.currentUser {
                                    Group {
                                        if let profileImage = user.profileImage {
                                            ImageLoader(profileImage, contentMode: .fill) { progress in
                                                Rectangle()
                                                    .foregroundStyle(.clear)
                                                    .frame(maxWidth: 150)
                                                    .overlay {
                                                        ProgressView(value: Double(progress.completedUnitCount), total: Double(progress.totalUnitCount))
                                                            .progressViewStyle(LinearProgressViewStyle())
                                                            .padding(.horizontal)
                                                    }
                                            }
                                        } else {
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                    .frame(width: 90, height: 90)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .foregroundStyle(Color.themePrimary)
                                    )
                                    .overlay {
                                        ZStack {
                                            Color.black.opacity(0.5)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                            PhotosPicker(
                                                selection: $vm.imageSelection,
                                                matching: .images,
                                                photoLibrary: .shared()
                                            ) {
                                                if !vm.isDeleting {
                                                    Image(systemName: "square.and.pencil")
                                                        .font(.system(size: 36))
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundStyle(.white)
                                                }
                                                
                                            }
                                        }
                                    }
                                    .clipShape(.rect(cornerRadius: 15))
                                } else {
                                    Color.themePrimary
                                        .frame(width: 90, height: 90)
                                        .background(Color.themePrimary)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .overlay {
                                            PhotosPicker(
                                                selection: $vm.imageSelection,
                                                matching: .images,
                                                photoLibrary: .shared()
                                            ) {
                                                Image(systemName: "photo.badge.plus.fill")
                                                    .font(.system(size: 36))
                                                    .symbolRenderingMode(.hierarchical)
                                                    .foregroundStyle(.primary)
                                            }.foregroundStyle(.primary)
                                        }
                                }
                            case .loading:
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(width: 90, height: 90)
                                    .foregroundStyle(.tertiary)
                                    .overlay {
                                        ProgressView()
                                    }
                            case .failure:
                                self.profileImage(image: Image(systemName: "exclamationmark.triangle.fill"))
                                    .overlay {
                                        ZStack {
                                            Color.black.opacity(0.5)
                                            PhotosPicker(
                                                selection: $vm.imageSelection,
                                                matching: .images,
                                                photoLibrary: .shared()
                                            ) {
                                                if !vm.isDeleting {
                                                    Image(systemName: "square.and.pencil")
                                                        .font(.system(size: 36))
                                                        .symbolRenderingMode(.hierarchical)
                                                        .foregroundStyle(.white)
                                                }
                                                
                                            }
                                        }
                                    }
                            }
                            
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
                                    vm.toggleImageDeletion()
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
                                .frame(width: 90, alignment: .leading)
                            
                            VStack {
                                TextField("Name", text: $vm.name)
                                Divider()
                            }
                        }
                        HStack(alignment: .top) {
                            Text("Username")
                                .cfont(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 90, alignment: .leading)
                            
                            VStack {
                                TextField("Username", text: $vm.username)
                                    .keyboardType(.default)
                                    .autocorrectionDisabled(true)
                                    .overlay(
                                        HStack {
                                            if vm.username.count > 0 {
                                                if vm.isLoading {
                                                    ProgressView()
                                                } else {
                                                    vm.isUsernameValid ?
                                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green) :
                                                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                                }
                                            }
                                        },
                                        alignment: .trailing
                                    )
                                Divider()
                            }
                        }
                        HStack(alignment: .top) {
                            Text("Bio")
                                .cfont(.headline)
                                .foregroundStyle(.secondary)
                                .frame(width: 90, alignment: .leading)
                            
                            VStack(spacing: 0) {
                                TextField("Bio", text: $vm.bio, axis: .vertical)
                                    .lineLimit(4...6)
                                    .overlay {
                                        if vm.bio.count > 0 {
                                            Text("\(vm.bio.count)/250")
                                                .foregroundStyle(vm.bio.count > 250 ? .red : Color.secondary)
                                                .padding(.bottom, 8)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                        }
                                    }
                                    
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    if let user = auth.currentUser {
                        vm.name = user.name
                        vm.username = user.username
                        vm.bio = user.bio ?? ""
                    }
                }
            }
        }
    }
}

extension EditProfileView {
    func profileImage(image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color.themePrimary)
            )
            .clipShape(.rect(cornerRadius: 15))
            
    }
}

#Preview {
    EditProfileView()
}
