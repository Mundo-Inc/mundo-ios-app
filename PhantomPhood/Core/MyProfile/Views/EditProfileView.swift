//
//  EditProfileView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 17.09.2023.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var auth: Authentication
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm = EditProfileViewModel()
    
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
                                print(error)
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            if vm.isSubmitting {
                                ProgressView()
                            }
                            Text("Save")
                        }.animation(.none, value: vm.isSubmitting)
                    }
                    .disabled(vm.isSubmitting)
                    
                }.padding(.horizontal)
                
                Divider()
                
                ScrollView {
                    Text("Profile Picture")
                        .font(.custom(style: .headline))
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
                                if let profileImage = auth.user?.profileImage {
                                    AsyncImage(url: URL(string: profileImage)) { phase in
                                        if let image = phase.image {
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
                                        } else if phase.error != nil {
                                            VStack(spacing: 0) {
                                                Image(systemName: "exclamationmark.icloud")
                                                    .font(.system(size: 42))
                                                    .symbolRenderingMode(.hierarchical)
                                                    .foregroundStyle(.red)
                                                Text("Error")
                                                    .font(.custom(style: .caption))
                                            }
                                            .frame(width: 90, height: 90)
                                            .background(Color.themeBG)
                                            .clipShape(
                                                .rect(
                                                    topLeadingRadius: 15,
                                                    bottomLeadingRadius: 15,
                                                    bottomTrailingRadius: 15,
                                                    topTrailingRadius: 15
                                                )
                                            )
                                        } else {
                                            RoundedRectangle(cornerRadius: 15)
                                                .frame(width: 90, height: 90)
                                                .foregroundStyle(.tertiary)
                                                .overlay {
                                                    ProgressView()
                                                }
                                        }
                                    }
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
                            
                            Text(((auth.user?.profileImage) == nil) ? "Add" : vm.isDeleting ? "Removing" : "Edit")
                                .font(.custom(style: .caption))
                                .foregroundStyle(Color.accentColor)
                            
                        }
                        .scaleEffect(vm.isDeleting ? 0.8 : 1)
                        .offset(x: vm.isDeleting ? 10 : 0)
                        
                        
                        if let _ = auth.user?.profileImage {
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
                                        .font(.custom(style: .caption))
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
                                .font(.custom(style: .headline))
                                .foregroundStyle(.secondary)
                                .frame(width: 90, alignment: .leading)
                            
                            VStack {
                                TextField("Name", text: $vm.name)
                                Divider()
                            }
                        }
                        HStack(alignment: .top) {
                            Text("Username")
                                .font(.custom(style: .headline))
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
                                .font(.custom(style: .headline))
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
                    if let user = auth.user {
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
            .scaledToFill()
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color.themePrimary)
            )
            .clipShape(
                .rect(
                    topLeadingRadius: 15,
                    bottomLeadingRadius: 15,
                    bottomTrailingRadius: 15,
                    topTrailingRadius: 15
                )
            )
            
    }
}

#Preview {
    EditProfileView()
        .environmentObject(Authentication())
}
