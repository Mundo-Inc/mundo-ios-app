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
                    .font(.custom(style: .body))
            } icon: {
                Text(reaction.reaction)
            }
            .padding(.all, 5)
            .padding(.trailing, 5)
            .background(isSelected ? Color.accentColor.opacity(0.3) : Color.themePrimary)
            .font(.system(size: 18))
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
            HStack {
                Text(reaction.reaction)
                    .font(.system(size: 20))
                
                Text(String(reaction.count))
                    .font(.custom(style: .body))
                    .frame(maxWidth: .infinity)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .background(isSelected ? Color.accentColor.opacity(0.5) : Color.black.opacity(0.3))
            .background(.ultraThinMaterial)
            .overlay {
                Capsule()
                    .stroke(isSelected ? Color.accentColor : Color.black.opacity(0.1), lineWidth: 4)
            }
            .clipShape(Capsule())
        }
        .foregroundStyle(.primary)
    }
}


#Preview {
    VStack {
        ReactionLabel(reaction: Reaction(reaction: "😍", type: .emoji, count: 5), isSelected: false)
        ReactionLabel(reaction: Reaction(reaction: "🙌🏻", type: .emoji, count: 2), isSelected: true)
        
        Group {
            ForYouReactionLabel(reaction: Reaction(reaction: "😍", type: .emoji, count: 5), isSelected: false)
            ForYouReactionLabel(reaction: Reaction(reaction: "🙌🏻", type: .emoji, count: 2), isSelected: true)
        }
        .frame(maxWidth: 80)
    }
}
