//
//  CTextField.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/29/24.
//

import SwiftUI

struct CTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let lengthLimit: Int?
    private let range: ClosedRange<Int>
    
    init(
        _ text: Binding<String>,
        placeholder: String,
        lengthLimit: Int? = nil,
        range: ClosedRange<Int> = 5...10
    ) {
        self._text = text
        self.placeholder = placeholder
        self.lengthLimit = lengthLimit
        self.range = range
    }
    
    var body: some View {
        if let lengthLimit {
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(range)
                .padding(.bottom, 34)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 8) {
                        Divider()
                        
                        HStack {
                            Spacer()
                            
                            Text("\(text.count)/\(lengthLimit)")
                                .foregroundStyle(text.count > lengthLimit ? Color.red : Color.secondary)
                                .cfont(.caption)
                        }
                    }
                    .frame(height: 20)
                    .padding(.bottom, 12)
                }
                .padding(.horizontal)
                .padding(.top)
                .background(Color.themePrimary, in: .rect(cornerRadius: 10))
        } else {
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(range)
                .padding()
                .background(Color.themePrimary, in: .rect(cornerRadius: 10))
        }
        
    }
}

#Preview {
    CTextField(.constant(""), placeholder: "Test placeholder")
}
