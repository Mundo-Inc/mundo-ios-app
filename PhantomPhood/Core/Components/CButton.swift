//
//  CButton.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/23/24.
//

import SwiftUI

struct CButton<Content: View>: View {
    private let size: ButtonSize
    private let color: ButtonColor
    private let action: () -> Void
    private let label: (() -> Content)?
    private let text: String?
    private let image: Image?
    
    init(size: ButtonSize = .md, color: ButtonColor = .primary, action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Content) {
        self.size = size
        self.color = color
        self.action = action
        self.label = label
        self.text = nil
        self.image = nil
    }
    
    init(size: ButtonSize = .md, color: ButtonColor = .primary, text: String, systemIcon: String? = nil, action: @escaping () -> Void) where Content == EmptyView {
        self.size = size
        self.color = color
        self.action = action
        self.label = nil
        self.text = text
        self.image = if let systemIcon { Image(systemName: systemIcon) } else { nil }
    }
    
    init(size: ButtonSize = .md, color: ButtonColor = .primary, text: String, image: Image? = nil, action: @escaping () -> Void) where Content == EmptyView {
        self.size = size
        self.color = color
        self.action = action
        self.label = nil
        self.text = text
        self.image = image
    }
    
    var body: some View {
        Button(action: self.action) {
            if let label {
                label()
                    .foregroundStyle(color.textColor)
                    .padding(.all, size.padding)
                    .background(color.bgColor, in: .rect(cornerRadius: size.cornerRadius))
            } else if let text {
                HStack(spacing: 5) {
                    if let image {
                        image
                    }
                    
                    Text(text)
                }
                .foregroundStyle(color.textColor)
                .padding(.vertical, size.padding)
                .padding(.horizontal, size.padding * 1.6)
                .background(color.bgColor, in: .rect(cornerRadius: size.cornerRadius))
            }
        }
        .cfont(size.font)
        .fontWeight(size.fontWeight)
    }
    
    enum ButtonColor {
        case primary
        case secondary
        
        var textColor: Color {
            switch self {
            case .primary:
                Color.white
            case .secondary:
                Color.accentColor
            }
        }
        
        var bgColor: Color {
            switch self {
            case .primary:
                Color.accentColor
            case .secondary:
                Color.themePrimary
            }
        }
    }
    
    enum ButtonSize {
        case sm
        case md
        case lg
        
        var padding: CGFloat {
            switch self {
            case .sm:
                6
            case .md:
                8
            case .lg:
                12
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .sm:
                6
            case .md:
                8
            case .lg:
                12
            }
        }
        
        var font: Font.TextStyle {
            switch self {
            case .sm:
                return .subheadline
            case .md:
                return .body
            case .lg:
                return .title3
            }
        }
        
        var fontWeight: Font.Weight {
            return .regular
        }
    }
}

#Preview {
    VStack {
        CButton {
            print(1)
        } label: {
            Label("Test", systemImage: "swift")
        }
        
        HStack {
            CButton(color: .primary, text: "Test", systemIcon: "swift") {
                
            }
            
            CButton(color: .secondary, text: "Test", systemIcon: "swift") {
                
            }
        }
        HStack {
            CButton(size: .sm, color: .primary, text: "Test", systemIcon: "swift") {
                
            }
            
            CButton(color: .secondary, text: "Test", systemIcon: "swift") {
                
            }
            
            CButton(size: .lg, color: .secondary, text: "Test", systemIcon: "swift") {
                
            }
        }
    }
}
