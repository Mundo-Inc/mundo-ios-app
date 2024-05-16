//
//  Sticky.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 5/16/24.
//

import SwiftUI

struct Sticky: ViewModifier {
    let coordinateSpaceName: String
    
    @State private var frame: CGRect = .zero
    
    var isSticking: Bool {
        frame.minY < 0
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: isSticking ? -frame.minY : 0)
            .zIndex(isSticking ? 1000 : 0)
            .background(GeometryReader(content: { proxy in
                let f = proxy.frame(in: .named(coordinateSpaceName))
                Color.clear
                    .onAppear { frame = f }
                    .onChange(of: f) { frame = $0 }
            }))
    }
}

extension View {
    /// Makes the view sticky within a specified coordinate space.
    /// - Parameter coordinateSpaceName: The name of the coordinate space.
    /// - Returns: A view that sticks within the specified coordinate space.
    func sticky(_ coordinateSpaceName: String) -> some View {
        modifier(Sticky(coordinateSpaceName: coordinateSpaceName))
    }
}
