//
//  CoreLocation.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 7/26/24.
//

import Foundation
import CoreLocation

extension CLPlacemark {
    enum AddressType {
        case short
        case local
        case long
    }
    
    func getAddress(ofType type: AddressType) -> String? {
        var components: [String] = []
        
        switch type {
        case .short:
            if let locality = self.locality {
                components.append(locality)
            }
            if let administrativeArea = self.administrativeArea {
                components.append(administrativeArea)
            }
            if let country = self.country {
                components.append(country)
            }
            
        case .local:
            if let thoroughfare = self.thoroughfare {
                components.append(thoroughfare)
            }
            if let locality = self.locality {
                components.append(locality)
            }
            if let administrativeArea = self.administrativeArea {
                components.append(administrativeArea)
            }
            
        case .long:
            if let thoroughfare = self.thoroughfare {
                components.append(thoroughfare)
            }
            if let subThoroughfare = self.subThoroughfare {
                components.append(subThoroughfare)
            }
            if let locality = self.locality {
                components.append(locality)
            }
            if let administrativeArea = self.administrativeArea {
                components.append(administrativeArea)
            }
            if let postalCode = self.postalCode {
                components.append(postalCode)
            }
            if let country = self.country {
                components.append(country)
            }
        }
        
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}
