//
//  MediasVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/5/23.
//

import Foundation
import Combine

@MainActor
final class MediasVM: ObservableObject {
    @Published var show = false
    @Published var medias: [MediaItem] = []
        
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $show
            .sink { newValue in
                if !newValue {
                    self.medias.removeAll()
                }
            }
            .store(in: &cancellables)
    }
    
    func show(medias: [MediaItem]) {
        self.medias = medias
        self.show = true
    }
}
