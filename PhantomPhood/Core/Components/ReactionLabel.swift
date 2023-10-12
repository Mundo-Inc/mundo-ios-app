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
            } icon: {
                Text(reaction.reaction)
            }
            .padding(.all, 5)
            .padding(.trailing, 5)
            .background(isSelected ? Color.accentColor.opacity(0.3) : Color.themePrimary)
            .font(.custom(style: .caption))
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.accentColor : Color.themePrimary, lineWidth: 2)
            }
            .clipShape(.rect(cornerRadius: 25))
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    Group {
        ReactionLabel(reaction: Reaction(reaction: "😍", type: .emoji, count: 5), isSelected: false)
        ReactionLabel(reaction: Reaction(reaction: "🙌🏻", type: .emoji, count: 2), isSelected: true)
    }
}
