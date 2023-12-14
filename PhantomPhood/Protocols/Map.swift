//
//  Map.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/13/23.
//

import Foundation
import MapKit

protocol CoordinateRepresentable {
    var latitude: CLLocationDegrees { get }
    var longitude: CLLocationDegrees { get }
}
