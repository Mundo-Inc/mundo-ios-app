//
//  LineArchShape.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

import SwiftUI

fileprivate struct LineArchShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - rect.width))
            path.addArc(
                center: CGPoint(x: rect.maxX, y: rect.maxY - rect.width),
                radius: rect.width,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: 90),
                clockwise: true
            )
        }
    }
}

fileprivate struct LineArchView: View {
    var body: some View {
        LineArchShape()
            .stroke(Color.themeBorder, lineWidth: 2)
    }
}


#Preview {
    LineArchView()
        .frame(width: 20)
}
