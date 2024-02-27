//
//  CameraPreview.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/27/24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let vm: any HasCaptureSession
    let size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: vm.session)
        previewLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}


#Preview {
    CameraPreview(vm: PhotoCaptureVM(), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
}
