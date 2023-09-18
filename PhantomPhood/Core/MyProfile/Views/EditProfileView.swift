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
        
    let test: String? = "https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg"
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Save")
                }
            }.padding(.horizontal)
            
            Divider()
            
            ScrollView {
                Text("Profile Picture")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Spacer()
                    VStack {
                        switch vm.imageState {
                        case .success(let image):
                            self.profileImage(image: image)
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
                        case .empty:
                            if let profileImage = auth.user?.profileImage {
                                AsyncImage(url: URL(string: profileImage)) { phase in
                                    if let image = phase.image {
                                        self.profileImage(image: image)
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
                                    } else if phase.error != nil {
                                        VStack(spacing: 0) {
                                            Image(systemName: "exclamationmark.icloud")
                                                .font(.system(size: 42))
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(.red)
                                            Text("Error")
                                                .font(.caption)
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
                            .font(.caption)
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
                                    .font(.caption)
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
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(width: 90, alignment: .leading)
                                                
                        VStack {
                            TextField("Name", text: $vm.name)
                            Divider()
                        }
                    }
                    HStack(alignment: .top) {
                        Text("Username")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(width: 90, alignment: .leading)
                        
                        VStack {
                            TextField("Username", text: $vm.username)
                            Divider()
                        }
                    }
                    HStack(alignment: .top) {
                        Text("Bio")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(width: 90, alignment: .leading)
                        
                        VStack(spacing: 0) {
                            TextEditor(text: $vm.bio)
                                .multilineTextAlignment(.leading)
                                .padding(.all, 0)
                                .frame(minHeight: 100)
                                .overlay {
                                    if vm.bio.count == 0 {
                                        Text("Bio")
                                            .padding(.top, 9)
                                            .padding(.leading, 2)
                                            .foregroundStyle(.tertiary)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    } else {
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
