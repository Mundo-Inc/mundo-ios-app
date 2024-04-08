//
//  LocationManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 10/8/23.
//

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published private(set) var location: CLLocation?
    
    private(set) var isAuthorized: Bool = false
    private let locationManager = CLLocationManager()
    //    private let searchDM = SearchDM()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        configureBackgroundLocationUpdates()
    }
    
    private func configureBackgroundLocationUpdates() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        guard isAuthorized else { return }
        DispatchQueue.global(qos: .background).async {
            self.locationManager.stopUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    @objc private func appDidBecomeActive() {
        guard isAuthorized else { return }
        DispatchQueue.global(qos: .background).async {
            self.locationManager.stopMonitoringSignificantLocationChanges()
            self.locationManager.startUpdatingLocation()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            self.isAuthorized = false
            print("Location access denied or restricted")
        case .authorizedWhenInUse, .authorizedAlways:
            self.isAuthorized = true
            locationManager.startUpdatingLocation()
        @unknown default:
            self.isAuthorized = false
            print("Unknown authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.location = location
        }
        
        // MARK: - if is admin
        //        guard UserSettings.shared.userRole == .admin && UserSettings.shared.isBetaTester else { return }
        //
        //        Task {
        //            guard
        //                let mapItems = try? await searchDM.searchAppleMapsPlaces(region: MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 20, longitudinalMeters: 20)),
        //                let place = mapItems.first
        //            else { return }
        //
        //            let content = UNMutableNotificationContent()
        //            content.title = "Are you here?"
        //            content.subtitle = place.name ?? "-"
        //            content.body = place.placemark.title ?? "-"
        //            content.sound = UNNotificationSound.default
        //
        //            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        //            let request = UNNotificationRequest(identifier: "PhantomPhood", content: content, trigger: trigger)
        //
        //            try? await UNUserNotificationCenter.current().add(request)
        //        }
    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
//        print(error)
//    }
}
