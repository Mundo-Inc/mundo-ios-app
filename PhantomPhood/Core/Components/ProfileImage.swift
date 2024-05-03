//
//  ProfileImage.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/17/23.
//

import SwiftUI

struct ProfileImage<BorderStyle>: View where BorderStyle: ShapeStyle {
    private let profileImage: URL?
    private let size: CGFloat
    private let cornerRadius: CGFloat
    private let innerCornerRadius: CGFloat
    private let borderColor: BorderStyle
    private let borderSize: CGFloat?
    private let shadow: Color
    private let shadowSize: CGFloat
    
    init(
        _ url: URL?,
        size: CGFloat = 80,
        cornerRadius: CGFloat? = nil,
        borderColor: BorderStyle = .profileImageStroke,
        shadow: Color = Color.black.opacity(0.25),
        borderSize: CGFloat? = nil
    ) {
        self.profileImage = url
        self.size = size
        
        if let cornerRadius {
            self.cornerRadius = cornerRadius >= self.size / 2 ? self.size / 2 : cornerRadius
        } else {
            self.cornerRadius = self.size / 2
        }
        self.innerCornerRadius = self.cornerRadius >= size / 2 ? size / 2 : self.cornerRadius * 0.7
        
        self.borderColor = borderColor
        self.borderSize = borderSize ?? (size * 0.05)
        
        self.shadow = shadow
        self.shadowSize = min(10 * (size / 80), 10)
        
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundStyle(borderColor)
            .shadow(color: shadow, radius: shadowSize, y: shadowSize)
            .overlay {
                RoundedRectangle(cornerRadius: innerCornerRadius)
                    .foregroundStyle(Color.profileImageBG)
                    .overlay {
                        if let profileImage {
                            ImageLoader(profileImage, contentMode: .fill) { _ in
                                RoundedRectangle(cornerRadius: innerCornerRadius)
                                    .foregroundStyle(.tertiary)
                            }
                        } else {
                            Image(.noProfile)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .contentShape(RoundedRectangle(cornerRadius: innerCornerRadius))
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: innerCornerRadius))
                    .padding(.all, borderSize)
            }
            .frame(width: size, height: size)
    }
}

struct ProfileImageBase: View {
    private let profileImage: URL?
    private let size: CGFloat
    private let cornerRadius: CGFloat
    
    init(
        _ url: URL?,
        size: CGFloat = 80,
        cornerRadius: CGFloat? = nil
    ) {
        self.profileImage = url
        self.size = size
        
        if let cornerRadius {
            self.cornerRadius = cornerRadius >= self.size / 2 ? self.size / 2 : cornerRadius
        } else {
            self.cornerRadius = self.size / 2
        }
    }
    
    var body: some View {
        if let profileImage {
            ImageLoader(profileImage, contentMode: .fill) { _ in
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(.tertiary)
            }
            .frame(width: size, height: size)
            .background(Color.profileImageBG)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            Image(.noProfile)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .background(Color.profileImageBG)
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

#Preview {
    VStack {
        HStack {
            VStack {
                ProfileImageBase(URL(string:"https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg"))
                ProfileImageBase(nil)
            }
            VStack {
                ProfileImageBase(URL(string:"https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg"), cornerRadius: 10)
                ProfileImageBase(nil, cornerRadius: 10)
            }
        }
        
        HStack {
            VStack {
                ProfileImage(URL(string:"https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg"))
                ProfileImage(nil)
                ProfileImage(nil, size: 150)
            }
            VStack {
                ProfileImage(URL(string:"https://phantom-localdev.s3.us-west-1.amazonaws.com/645c8b222134643c020860a5/profile.jpg"), cornerRadius: 10)
                ProfileImage(nil, cornerRadius: 10)
                ProfileImage(nil, size: 150, cornerRadius: 10)
            }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
