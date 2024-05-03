//
//  HomeActivityItemPlaceholder.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/20/23.
//

import SwiftUI

struct HomeActivityItemPlaceholder: View {
    @Environment(\.mainWindowSize) private var mainWindowSize
    @Environment(\.mainWindowSafeAreaInsets) private var mainWindowSafeAreaInsets
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.themePrimary)
            
            LinearGradient(
                colors: [.black.opacity(0.3), .clear, .clear, .black.opacity(0.2), .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
            
            VStack(spacing: 0) {
                HeaderContent()
                    .redacted(reason: .placeholder)
                
                HStack(spacing: 0) {
                    FooterCotnent()
                        .frame(maxWidth: .infinity)
                        .redacted(reason: .placeholder)
                    
                    SideBar()
                        .frame(width: HomeActivityItem.sideBarWidth)
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.top, mainWindowSafeAreaInsets.top + HomeView.headerHeight)
            .padding(.bottom) // Because of action button
        }
    }
    
    @ViewBuilder
    private func HeaderContent() -> some View {
        HStack {
            ProfileImage(nil, size: 54)
                .overlay(alignment: .bottom) {
                    LevelView(level: 50)
                        .shadow(radius: 3)
                        .frame(width: 26, height: 30)
                        .offset(y: 15)
                }
            
            VStack(spacing: 4) {
                HStack {
                    Text("item.user.name")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("Message")
                    }
                    .frame(height: 25)
                    .frame(maxWidth: 80)
                    .font(.custom(style: .caption))
                    .fontWeight(.regular)
                    .background(Color.accentColor)
                    .clipShape(.rect(cornerRadius: 15))
                    .foregroundStyle(Color.primary)
                }
                .frame(height: 25)
                
                Spacer()
                    .frame(minHeight: 0)
                
                HStack() {
                    HStack(spacing: 5) {
                        Image(.Icons.restaurant)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        
                        Text("place.name")
                            .lineLimit(1)
                        
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 10))
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("1h")
                        .font(.custom(style: .caption))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 54)
        .padding(.all, 10)
        .background(.ultraThinMaterial.opacity(0.65).shadow(.drop(radius: 5)), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.top)
    }
    
    @ViewBuilder
    private func FooterCotnent() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            
            ContentTypeChip(text: "Check In", color: .themeBorder)
            
            TaggedUser()
            TaggedUser()
            
            Text("Caption placeholder. Caption placeholder. Caption placeholder. Caption placeholder")
                .lineLimit(5)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func SideBar() -> some View {
        VStack(spacing: 6) {
            Spacer()
            
            Group {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 3) {
                        Circle()
                            .frame(width: 36, height: 36)
                            .foregroundStyle(Color.themeBorder)
                            .opacity(0.5)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.themeBorder)
                            .opacity(0.3)
                    }
                }
            }
            .frame(width: 52, height: 36)
            .redacted(reason: .placeholder)
            
            Image(.Icons.addReaction)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 28)
                .frame(width: 52, height: 52)
                .foregroundStyle(.white)
                .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                .background(.bar.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
            
            Image(.Icons.addReview)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 28)
                .frame(width: 52, height: 52)
                .foregroundStyle(.white)
                .background(Color.black.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                .background(.bar.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.clear)
                .frame(width: 40, height: 40)
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.clear)
                .frame(width: 40, height: 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func ContentTypeChip(text: String, color: Color) -> some View {
        Text(text)
            .font(.custom(style: .caption))
            .fontWeight(.medium)
            .foregroundStyle(.black)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(color.opacity(0.8))
            .clipShape(.rect(cornerRadius: 5))
    }
    
    @ViewBuilder
    private func TaggedUser() -> some View {
        HStack(spacing: 5) {
            ProfileImage(nil, size: 28)
            
            Text("user.username")
                .font(.custom(style: .caption))
                .foregroundStyle(.white)
                .fontWeight(.medium)
            
            Image(systemName: "chevron.forward")
                .font(.system(size: 10))
                .fontWeight(.bold)
            
            Spacer()
        }
    }
}

#Preview {
    HomeActivityItemPlaceholder()
}
