//
//  CButton.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/23/24.
//

import SwiftUI

struct CButton<Content: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    
    private let size: ButtonSize
    private let variant: Variant
    private let action: () -> Void
    private let label: (() -> Content)?
    private let text: String?
    private let image: Image?
    private let fullWidth: Bool
    private let cornerRadius: CGFloat?
    private let isLoading: Bool
    
    init(
        fullWidth: Bool = false,
        size: ButtonSize = .md,
        variant: Variant = .primary,
        cornerRadius: CGFloat? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.size = size
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
        self.label = label
        self.text = nil
        self.image = nil
        self.fullWidth = fullWidth
        self.cornerRadius = cornerRadius
    }
    
    init(
        fullWidth: Bool = false,
        size: ButtonSize = .md,
        variant: Variant = .primary,
        cornerRadius: CGFloat? = nil,
        text: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) where Content == EmptyView {
        self.size = size
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
        self.label = nil
        self.text = text
        self.image = nil
        self.fullWidth = fullWidth
        self.cornerRadius = cornerRadius
    }
    
    init(
        fullWidth: Bool = false,
        size: ButtonSize = .md,
        variant: Variant = .primary,
        cornerRadius: CGFloat? = nil,
        text: String,
        systemImage: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) where Content == EmptyView {
        self.size = size
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
        self.label = nil
        self.text = text
        self.image = Image(systemName: systemImage)
        self.fullWidth = fullWidth
        self.cornerRadius = cornerRadius
    }
    
    init(
        fullWidth: Bool = false,
        size: ButtonSize = .md,
        variant: Variant = .primary,
        cornerRadius: CGFloat? = nil,
        text: String,
        image: Image,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) where Content == EmptyView {
        self.size = size
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
        self.label = nil
        self.text = text
        self.image = image
        self.fullWidth = fullWidth
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let label {
                    label()
                } else if let text {
                    HStack(spacing: 5) {
                        if let image {
                            image
                        }
                        
                        Text(text)
                    }
                }
            }
            .opacity(isLoading ? 0 : 1)
            .foregroundStyle(variant.textColor.opacity(isEnabled ? 1 : 0.4))
            .padding(.horizontal, size.padding)
            .frame(height: size.height)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(isEnabled ? variant.bgColor : Color.themeBorder.opacity(0.5), in: .rect(cornerRadius: cornerRadius ?? size.cornerRadius))
            .overlay {
                if isLoading {
                    ProgressView()
                }
            }
        }
        .cfont(size.font)
        .fontWeight(size.fontWeight)
    }
    
    enum Variant {
        case primary
        case secondary
        case ghost
        
        var textColor: Color {
            switch self {
            case .primary:
                Color.white
            case .secondary:
                Color.accentColor
            case .ghost:
                Color.accentColor
            }
        }
        
        var bgColor: Color {
            switch self {
            case .primary:
                Color.accentColor
            case .secondary:
                Color.themePrimary
            case .ghost:
                Color.clear
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
                10
            case .md:
                16
            case .lg:
                24
            }
        }
        
        var height: CGFloat {
            switch self {
            case .sm:
                28
            case .md:
                38
            case .lg:
                48
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
                return .headline
            }
        }
        
        var fontWeight: Font.Weight {
            switch self {
            case .sm:
                return .regular
            case .md:
                return .regular
            case .lg:
                return .bold
            }
        }
    }
}

#Preview {
    VStack {
        CButton {
            
        } label: {
            Label("Test", systemImage: "swift")
        }
        
        HStack {
            CButton(variant: .primary, text: "Test", systemImage: "swift") {
                
            }
            
            CButton(variant: .secondary, text: "Test", systemImage: "swift") {
                
            }
        }
        HStack {
            CButton(size: .sm, variant: .primary, text: "Test", systemImage: "swift") {
                
            }
            
            CButton(variant: .ghost, text: "Test", systemImage: "swift") {
                
            }
            
            CButton(variant: .secondary, text: "Test", systemImage: "swift") {
                
            }
            
            CButton(size: .lg, variant: .secondary, text: "Test", systemImage: "swift") {
                
            }
        }
        HStack {
            CButton(size: .sm, variant: .primary, text: "Test", systemImage: "swift", isLoading: true) {
                
            }
            
            CButton(variant: .ghost, text: "Test", systemImage: "swift", isLoading: true) {
                
            }
            
            CButton(variant: .secondary, text: "Test", systemImage: "swift", isLoading: true) {
                
            }
            
            CButton(size: .lg, variant: .secondary, text: "Test", systemImage: "swift", isLoading: true) {
                
            }
        }
    }
}
