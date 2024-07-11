//
//  ReactionLabel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/6/23.
//

import SwiftUI

struct ReactionLabel: View {
    let reaction: Reaction
    let isSelected: Bool
    let onPress: ((_ isSelected: Bool) -> Void)?
    
    init(reaction: Reaction, isSelected: Bool, onPress: @escaping (_: Bool) -> Void = { _ in }) {
        self.reaction = reaction
        self.isSelected = isSelected
        self.onPress = onPress
    }
    
    var body: some View {
        Button {
            onPress?(isSelected)
        } label: {
            Label {
                Text(String(reaction.count))
                    .cfont(.body)
            } icon: {
                Emoji(reaction: reaction, isAnimating: Binding(get: {
                    isSelected
                }, set: { _ in }), size: 18)
            }
            .padding(.all, 5)
            .padding(.trailing, 5)
            .background(isSelected ? Color.accentColor.opacity(0.3) : Color.themePrimary)
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.accentColor : Color.themePrimary, lineWidth: 2)
            }
            .clipShape(.rect(cornerRadius: 25))
        }
        .foregroundStyle(.primary)
    }
}

struct ForYouReactionLabel: View {
    let reaction: Reaction
    let isSelected: Bool
    let orientation: Orientation
    let size: CGFloat
    let onPress: (_ isSelected: Bool) -> Void
    
    init(reaction: Reaction, isSelected: Bool, size: CGFloat = 36, orientation: Orientation = .horizontal, onPress: @escaping (Bool) -> Void) {
        self.reaction = reaction
        self.isSelected = isSelected
        self.size = size
        self.orientation = orientation
        self.onPress = onPress
    }
    
    enum Orientation {
        case vertical
        case horizontal
    }
    
    var body: some View {
        Button {
            onPress(isSelected)
        } label: {
            switch orientation {
            case .vertical:
                VStack(spacing: 3) {
                    Emoji(reaction: reaction, isAnimating: Binding(get: {
                        isSelected
                    }, set: { _ in }), size: size)
                    
                    Text(String(reaction.count))
                        .foregroundStyle(Color.white)
                        .cfont(.caption2)
                        .frame(height: 20)
                        .frame(minWidth: 20)
                        .background(.ultraThinMaterial.opacity(0.65), in: RoundedRectangle(cornerRadius: 5))
                        .background(isSelected ? Color.accentColor : Color.clear, in: RoundedRectangle(cornerRadius: 5))
                }
            case .horizontal:
                HStack(spacing: 3) {
                    Emoji(reaction: reaction, isAnimating: Binding(get: {
                        isSelected
                    }, set: { _ in }), size: size)
                    
                    Text(String(reaction.count))
                        .foregroundStyle(Color.white)
                        .cfont(.caption2)
                        .frame(height: 20)
                        .frame(minWidth: 20)
                        .background(.ultraThinMaterial.opacity(0.65), in: RoundedRectangle(cornerRadius: 5))
                        .background(isSelected ? Color.accentColor : Color.clear, in: RoundedRectangle(cornerRadius: 5))
                }
            }
        }
    }
}


#Preview {
    VStack {
        ReactionLabel(reaction: Reaction(reaction: "😍", type: .emoji, count: 5), isSelected: false)
        ReactionLabel(reaction: Reaction(reaction: "🙌🏻", type: .emoji, count: 2), isSelected: true)
//        
//        Group {
//            ForYouReactionLabel(reaction: Reaction(reaction: "😍", type: .emoji, count: 5), isSelected: false)
//            ForYouReactionLabel(reaction: Reaction(reaction: "🙌🏻", type: .emoji, count: 2), isSelected: true)
//        }
//        .frame(maxWidth: 80)
    }
}
