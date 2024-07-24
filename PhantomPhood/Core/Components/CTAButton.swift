//
//  CTAButton.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/13/24.
//

import SwiftUI

struct CTAButton<Content>: View where Content: View {
    private let action: () -> Void
    private let label: () -> Content
    
    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Content) {
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(action: self.action) {
            label()
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.black.opacity(0.85))
                .padding(.vertical, 12)
                .background(Color.accentColor, in: .rect(cornerRadius: 10))
        }
        .cfont(.body)
        .fontWeight(.medium)
        .controlSize(.large)
    }
}

#Preview {
    CTAButton {
        print("Hi")
    } label: {
        Text("Submit")
    }

}
