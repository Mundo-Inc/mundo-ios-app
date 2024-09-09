//
//  CollapsableSection.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/6/24.
//

import SwiftUI

struct CollapsableSection<Content: View>: View {
    @Binding private var isExpanded: Bool
    private let title: String
    private let content: Content
    
    init(isExpanded: Binding<Bool>, title: String, @ViewBuilder content: @escaping () -> Content) {
        self._isExpanded = isExpanded
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            Section(title, isExpanded: $isExpanded) {
                content
            }
        } else {
            Section {
                if isExpanded {
                    content
                }
            } header: {
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text(title)
                            .foregroundStyle(Color.secondary)
                        
                        Spacer()
                        
                        Text(isExpanded ? "Hide" : "Show")
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
    }
}

#Preview {
    CollapsableSection(isExpanded: .constant(true), title: "Title") {
        Text("Content")
    }
}
