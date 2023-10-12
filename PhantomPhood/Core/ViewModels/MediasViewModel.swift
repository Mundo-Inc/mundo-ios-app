//
//  MediasViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/5/23.
//

import Foundation
import Combine

class MediasViewModel: ObservableObject {
    @Published var show = false
    @Published var medias: [Media] = []
        
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
    
    func show(medias: [Media]) {
        self.medias = medias
        self.show = true
    }
}
