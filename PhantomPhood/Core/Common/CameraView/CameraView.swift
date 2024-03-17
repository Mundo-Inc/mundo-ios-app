//
//  CameraView.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/27/24.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var vm = CameraVM()
    
    private let onCompletion: (Data) -> Void
    
    init(onCompletion: @MainActor @escaping (Data) -> Void) {
        self.onCompletion = onCompletion
    }
    
    var body: some View {
        ZStack {
            PhotoCaptureView(onCompletion: onCompletion)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CameraView(onCompletion: { _ in })
}
