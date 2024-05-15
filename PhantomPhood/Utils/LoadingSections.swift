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
    func setLoadingState(_ section: LoadingSection, to: Bool) {
        if to {
            DispatchQueue.main.async {
                self.loadingSections.insert(section)
            }
        } else {
            DispatchQueue.main.async {
                self.loadingSections.remove(section)
            }
        }
    }
}
