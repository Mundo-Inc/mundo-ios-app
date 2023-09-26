//
//  MapViewModel.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 19.09.2023.
//

import Foundation
import SwiftUI
import MapKit

@available(iOS 17.0, *)
class MapViewModel: ObservableObject {
    @Published var position: MapCameraPosition = .automatic
}
