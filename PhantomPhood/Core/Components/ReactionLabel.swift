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
    private let reaction: Reaction
    private let isSelected: Bool
    private let size: CGFloat
    private let onPress: (_ isSelected: Bool) -> Void
    private let isAnimating: Bool
    
    init(reaction: Reaction, isSelected: Bool, size: CGFloat = 28, isAnimating: Bool = true, onPress: @escaping (Bool) -> Void) {
        self.reaction = reaction
        self.isSelected = isSelected
        self.size = size
        self.onPress = onPress
        self.isAnimating = isAnimating
    }
    
    enum Orientation {
        case vertical
        case horizontal
    }
    
    var body: some View {
        Button {
            onPress(isSelected)
        } label: {
            Emoji(reaction: reaction, isAnimating: Binding(get: {
                isAnimating
            }, set: { _ in }), size: size)
            .grayscale(isSelected ? 0 : 0.9)
            .opacity(isSelected ? 1 : 0.8)
        }
    }
}

struct VerticalReactionLabel: View {
    let reaction: Reaction
    let isSelected: Bool
    let size: CGFloat
    let onPress: (_ isSelected: Bool) -> Void
    
    init(reaction: Reaction, isSelected: Bool, size: CGFloat = 36, onPress: @escaping (Bool) -> Void) {
        self.reaction = reaction
        self.isSelected = isSelected
        self.size = size
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
        }
    }
}


#Preview {
    VStack {
        ReactionLabel(reaction: Reaction(reaction: "😍", type: .emoji, count: 5), isSelected: false)
        ReactionLabel(reaction: Reaction(reaction: "🙌🏻", type: .emoji, count: 2), isSelected: true)
    }
}
