//
//  PhotosPickerItem.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/10/23.
//

import Foundation
import PhotosUI
import SwiftUI

extension PhotosPickerItem {
    var isVideo: Bool {
        let videoTypes: Set<UTType> = [.mpeg4Movie, .movie, .video, .quickTimeMovie, .appleProtectedMPEG4Video, .avi, .mpeg, .mpeg2Video]
        return supportedContentTypes.contains(where: videoTypes.contains)
    }
    
    var isImage: Bool {
        let imageTypes: Set<UTType> = [.jpeg, .png, .gif, .tiff, .rawImage, .heic]
        return supportedContentTypes.contains(where: imageTypes.contains)
    }
}
