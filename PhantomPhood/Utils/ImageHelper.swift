//
//  ImageHelper.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/7/23.
//

import Foundation
import UIKit

struct ImageHelper {
    enum ImageFormat {
        case jpeg
        case png
    }
    
    /// Compresses a UIImage to the specified format and resize it
    /// - Parameters:
    ///   - uiImage: The UIImage to compress.
    ///   - compressionQuality: The quality of the compression for JPEG format (0.0 to 1.0). Ignored for PNG format.
    ///   - format: The desired image format (JPEG or PNG).
    /// - Returns: Compressed image data, or nil if compression fails. For JPEG, the quality is adjustable. For PNG, the compression is lossless.
    static func compress(uiImage: UIImage, compressionQuality: CGFloat = 0.7, format: ImageFormat = .jpeg) -> Data? {
        switch format {
        case .jpeg:
            return uiImage.jpegData(compressionQuality: compressionQuality)
        case .png:
            return uiImage.pngData()
        }
    }

    /// Resizes a UIImage to the specified size.
    /// - Parameters:
    ///   - image: The UIImage to resize
    ///   - targetSize: The desired size of the image
    /// - Returns: The resized image, or nil if resizing fails.
    /// - Note: The image is not cropped, and the aspect ratio is preserved.
    static func resize(uiImage: UIImage, targetSize: CGSize) -> UIImage? {
        let size = uiImage.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        uiImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
