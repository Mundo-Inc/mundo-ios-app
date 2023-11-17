//
//  ProfileImage.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/17/23.
//

import SwiftUI
import Kingfisher

struct ProfileImage: View {
    let profileImage: String
    let maxSize: CGFloat
    
    init(_ profileImage: String, maxSize: CGFloat = 80) {
        self.profileImage = profileImage
        self.maxSize = maxSize
    }
    
    var strokeSize: CGFloat {
        maxSize * 0.05
    }
    
    var body: some View {
        if !profileImage.isEmpty, let url = URL(string: profileImage) {
            Circle()
                .foregroundStyle(Color(.profileImageStroke))
                .shadow(color: .black.opacity(0.25), radius: 10, y: 10)
                .overlay {
                    Circle()
                        .foregroundStyle(Color(.profileImageBG))
                        .padding(.all, strokeSize)
                        .overlay {
                            KFImage.url(url)
                                .placeholder {
                                    Circle()
                                        .foregroundStyle(.tertiary)
                                }
                                .loadDiskFileSynchronously()
                                .cacheMemoryOnly()
                                .fade(duration: 0.25)
                                .onFailureImage(UIImage(named: "ErrorLoadingImage"))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .contentShape(Circle())
                                .clipShape(Circle())
                                .padding(.all, strokeSize)
                                .frame(width: maxSize, height: maxSize)
                        }
                }
                .frame(maxWidth: maxSize, maxHeight: maxSize)
        } else {
            Circle()
                .foregroundStyle(Color(.profileImageStroke))
                .shadow(color: .black.opacity(0.25), radius: 10, y: 10)
                .overlay {
                    Circle()
                        .foregroundStyle(Color(.profileImageBG))
                        .padding(.all, strokeSize)
                        .overlay {
                            Image(.noProfile)
                                .resizable()
                                .padding(.all, strokeSize)
                        }
                }
                .frame(maxWidth: maxSize, maxHeight: maxSize)
        }
    }
}

#Preview {
    VStack {
        ProfileImage("https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg")
        ProfileImage("")
        ProfileImage("", maxSize: 150)
    }
}
