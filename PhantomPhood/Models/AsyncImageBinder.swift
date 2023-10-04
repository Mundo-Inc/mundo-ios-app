//
//  AsyncImageBinder.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 9/28/23.
//

import Foundation
import Combine
import UIKit

class AsyncImageBinder: ObservableObject {
    enum ImageState {
        case loading
        case ready
        case error
    }
    
    private var subscription: AnyCancellable?
    @Published private(set) var image: UIImage?
    @Published private(set) var state: ImageState = .loading
    
    func load(url: URL) {
        subscription = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
//            .assign(to: \.image, on: self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break // No error, hence no state change here.
                case .failure:
                    self.state = .error // An error occurred, so set the state to error.
                }
            }, receiveValue: { newImage in
                if let _ = newImage {
                    self.state = .ready // Image loaded successfully, set the state to ready.
                } else {
                    self.state = .error // Image data was nil or couldn't be converted to UIImage.
                }
                self.image = newImage
            })
    }
    
    func cancel() {
        subscription?.cancel()
    }
}
