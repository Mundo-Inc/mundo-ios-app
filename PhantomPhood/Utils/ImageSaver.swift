//
//  ImageSaver.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/28/24.
//

import Foundation
import SwiftUI

final class ImageSaver: NSObject {
    private var callback: (UIImage, Error?, UnsafeRawPointer) -> Void
    
    init(callback: @escaping (UIImage, Error?, UnsafeRawPointer) -> Void = { _, _, _ in }) {
        self.callback = callback
    }
    
    func writeToPhotoAlbum(uiImage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(saveCompleted), nil)
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        callback(image, error, contextInfo)
    }
}
