//
//  PickerVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/7/23.
//

import Foundation
import PhotosUI
import SwiftUI

@MainActor
class PickerVM: ObservableObject {
    let taskManager = TaskManager.shared
    
    @Published var selection: [PhotosPickerItem] = [] {
        didSet {
            onSelectionChange()
        }
    }
    @Published private(set) var mediaItems: [MediaItem] = []
    
    var isReadyToSubmit: Bool {
        mediaItems.allSatisfy({ mediaItem in
            if case .loaded(_) = mediaItem.state {
                return true
            } else {
                return false
            }
        })
    }
    
    private func onSelectionChange() {
        self.mediaItems.removeAll()
        
        for item in selection {
            let id = item.itemIdentifier ?? UUID().uuidString
            let progress = loadTransferable(from: item, id: id)
            self.mediaItems.append(.init(id: id, state: .loading(progress)))
        }
    }
    
    private func loadTransferable(from pickerItem: PhotosPickerItem, id: String) -> Progress {
        if pickerItem.isVideo {
            return pickerItem.loadTransferable(type: Movie.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data?):
                        self.mediaItems = self.mediaItems.map({ item in
                            if item.id == id {
                                return item.newState(state: .loaded(.movie(data.url)))
                            }
                            return item
                        })
                    case .success(nil):
                        break
                        //                    self.mediaItemsState.removeAll { item in
                        //                        item.id == id
                        //                    }
                    case .failure(let error):
                        self.mediaItems = self.mediaItems.map({ item in
                            if item.id == id {
                                return item.newState(state: .failure(error))
                            }
                            return item
                        })
                    }
                }
            }
        } else {
            return pickerItem.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data?):
                        self.mediaItems = self.mediaItems.map({ item in
                            if item.id == id {
                                if let uiImage = UIImage(data: data) {
                                    return item.newState(state: .loaded(.image(uiImage)))
                                }
                            }
                            return item
                        })
                    case .success(nil):
                        break
                        //                    self.mediaItemsState.removeAll { item in
                        //                        item.id == id
                        //                    }
                    case .failure(let error):
                        self.mediaItems = self.mediaItems.map({ item in
                            if item.id == id {
                                return item.newState(state: .failure(error))
                            }
                            return item
                        })
                    }
                }
            }
        }
    }
}

struct MediaItem: Identifiable {
    let id: String
    var state: MediaItemState
    
    func newState(state newState: MediaItemState) -> MediaItem {
        return MediaItem(id: self.id, state: newState)
    }
}

enum MediaItemState {
    case empty
    case loading(Progress)
    case failure(Error)
    case loaded(MediaItemData.MediaData)
}

struct MediaItemData {
    let id: String
    var state: MediaData
    
    enum MediaData {
        case image(UIImage)
        case movie(URL)
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
