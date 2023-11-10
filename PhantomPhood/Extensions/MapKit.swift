//
//  MapKit.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 11/10/23.
//

import Foundation
import MapKit
import SwiftUI

extension MKPointOfInterestCategory {
    var image: Image {
        switch self {
        case .restaurant:
            Image(systemName: "fork.knife.circle.fill")
        case .cafe:
            Image(systemName: "cup.and.saucer.fill")
        case .bakery:
            Image(systemName: "storefront.fill")
        case .nightlife:
            Image(systemName: "mug.fill")
        case .winery:
            Image(systemName: "wineglass.fill")
        default:
            Image(systemName: "mappin.circle")
        }
    }
}
