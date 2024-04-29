//
//  LoadingSections.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 4/29/24.
//

import Foundation

protocol LoadingSections: AnyObject {
    associatedtype LoadingSection: Hashable
    
    var loadingSections: Set<LoadingSection> { get set }
}

extension LoadingSections {
    @MainActor
    func setLoadingState(_ section: LoadingSection, to: Bool) {
        if to {
            loadingSections.insert(section)
        } else {
            loadingSections.remove(section)
        }
    }
}
