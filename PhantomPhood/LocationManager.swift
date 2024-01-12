//
//  LocationManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/8/23.
//

import Foundation
import MapKit
import UserNotifications

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        // MARK: - if is admin
        guard UserSettings.shared.userRole == .admin && UserSettings.shared.isBetaTester else { return }
        
        let request = MKLocalPointsOfInterestRequest(center: location.coordinate, radius: 20)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.cafe, .restaurant, .nightlife, .bakery, .brewery, .winery])

        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response, let place = response.mapItems.first else { return }

            let content = UNMutableNotificationContent()
            content.title = "Are you here?"
            // point of interst
            content.subtitle = place.name ?? "-"
            content.body = place.placemark.title ?? "-"
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "PhantomPhood", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }
}
