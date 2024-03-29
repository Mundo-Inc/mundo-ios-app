//
//  ProfileImage.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/17/23.
//

import SwiftUI

struct ProfileImage: View {
    let profileImage: URL?
    let size: CGFloat
    let cornerRadius: CGFloat
    let borderColor: Color
    
    init(_ string: String?, size: CGFloat? = nil, cornerRadius: CGFloat? = nil, borderColor: Color = .profileImageStroke) {
        if let string, let url = URL(string: string) {
            self.profileImage = url
        } else {
            self.profileImage = nil
        }
        self.size = size ?? 80
        if let cornerRadius {
            self.cornerRadius = cornerRadius >= self.size / 2 ? self.size / 2 : cornerRadius
        } else {
            self.cornerRadius = self.size / 2
        }
        self.borderColor = borderColor
    }
    
    init(_ url: URL?, size: CGFloat? = nil, cornerRadius: CGFloat? = nil, borderColor: Color = .profileImageStroke) {
        self.profileImage = url
        self.size = size ?? 80
        if let cornerRadius {
            self.cornerRadius = cornerRadius >= self.size / 2 ? self.size / 2 : cornerRadius
        } else {
            self.cornerRadius = self.size / 2
        }
        self.borderColor = borderColor
    }
    
    var strokeSize: CGFloat {
        size * 0.05
    }
    
    var innerCornerRadius: CGFloat {
        cornerRadius >= size / 2 ? size / 2 : cornerRadius * 0.7
    }
    
    var shadowSize: CGFloat {
        min(10 * (size / 80), 10)
    }
    
    var body: some View {
        if let profileImage {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(borderColor)
                .shadow(color: Color.black.opacity(0.25), radius: shadowSize, y: shadowSize)
                .overlay {
                    RoundedRectangle(cornerRadius: innerCornerRadius)
                        .foregroundStyle(Color(.profileImageBG))
                        .overlay {
                            ImageLoader(profileImage, contentMode: .fill) { _ in
                                RoundedRectangle(cornerRadius: innerCornerRadius)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: innerCornerRadius))
                        .padding(.all, strokeSize)
                }
                .frame(width: size, height: size)
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(borderColor)
                .shadow(color: Color.black.opacity(0.25), radius: shadowSize, y: shadowSize)
                .overlay {
                    RoundedRectangle(cornerRadius: innerCornerRadius)
                        .foregroundStyle(Color(.profileImageBG))
                        .overlay {
                            Image(.noProfile)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .contentShape(RoundedRectangle(cornerRadius: innerCornerRadius))
                                .clipShape(RoundedRectangle(cornerRadius: innerCornerRadius))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: innerCornerRadius))
                        .padding(.all, strokeSize)
                }
                .frame(width: size, height: size)
        }
    }
}

#Preview {
    HStack {
        VStack {
            ProfileImage("https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg")
            ProfileImage("")
            ProfileImage("", size: 150)
        }
        VStack {
            ProfileImage("https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg", cornerRadius: 10)
            ProfileImage("", cornerRadius: 10)
            ProfileImage("", size: 150, cornerRadius: 10)
        }
    }
}
