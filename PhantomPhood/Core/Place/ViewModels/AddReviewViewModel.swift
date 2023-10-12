//
//  AddReviewViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/9/23.
//

import Foundation
import PhotosUI
import CoreTransferable
import SwiftUI

@MainActor
class AddReviewViewModel: ObservableObject {
    enum Steps {
        case recommendation
        case scores
        case review
    }
    
    private let apiManager = APIManager()
    private let auth = Authentication.shared
    
    @Published var step: Steps = .recommendation
    
    @Published var isRecommended: Bool? = nil
    @Published var overallScore: Int? = nil
    @Published var foodQuality: Int? = nil
    @Published var drinkQuality: Int? = nil
    @Published var service: Int? = nil
    @Published var atmosphere: Int? = nil
    
    @Published var isPublic = true
    @Published var reviewContent = ""

    var haveAnyScore: Bool {
        overallScore != nil || foodQuality != nil || drinkQuality != nil || service != nil || atmosphere != nil
    }
    
    @Published var selectedItems: [PhotosPickerItem] = [] {
        didSet {
            selectedMedia.removeAll()
            for item in selectedItems {
                if item.supportedContentTypes.contains(.jpeg) {
                    loadTransferable(from: item, type: .image)
                } else if item.supportedContentTypes.contains(.png) {
                    loadTransferable(from: item, type: .png)
                } else {
                    loadTransferable(from: item, type: .video)
                }
            }
        }
    }
    @Published var selectedMedia: [MediaState] = []
    
    enum MediaState {
        case empty
        case loading(Progress)
        case videoSuccess(Movie)
        case imageSuccess(Image)
        case failure(Error)
    }
    
    enum MediaType {
        case image
        case png
        case video
    }
    
    private func loadTransferable(from selectionItem: PhotosPickerItem, type: MediaType) -> Progress {
        switch type {
        case .image:
            return selectionItem.loadTransferable(type: Image.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let theMedia):
                        if let theMedia {
                            self.selectedMedia.append(.imageSuccess(theMedia))
                        } else {
                            selectionItem.loadTransferable(type: Data.self) { res in
                                switch res {
                                case .success(let mediaData):
                                    if let mediaData, let image = UIImage(data: mediaData) {
                                        self.selectedMedia.append(.imageSuccess(Image(uiImage: image)))
                                    }
                                case .failure(let error):
                                    self.selectedMedia.append(.failure(error))
                                }
                                
                            }
                        }
                    case .failure(let error):
                        self.selectedMedia.append(.failure(error))
                    }
                }
            }
        case .png:
            return selectionItem.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let mediaData):
                        if let mediaData, let image = UIImage(data: mediaData) {
                            self.selectedMedia.append(.imageSuccess(Image(uiImage: image)))
                        } else {
                            self.selectedMedia.append(.empty)
                        }
                    case .failure(let error):
                        self.selectedMedia.append(.failure(error))
                    }
                }
            }
        case .video:
            return selectionItem.loadTransferable(type: Movie.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let theMedia):
                        if let theMedia {
                            self.selectedMedia.append(.videoSuccess(theMedia))
                        } else {
                            self.selectedMedia.append(.empty)
                        }
                    case .failure(let error):
                        self.selectedMedia.append(.failure(error))
                    }
                }
            }
        }
        
    }

}


struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { receivedData in
            let fileName = receivedData.file.lastPathComponent
            let copy: URL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: copy.path) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: receivedData.file, to: copy)
            
            return .init(url: copy)
        }
    }
}

