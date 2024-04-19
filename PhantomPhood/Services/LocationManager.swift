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
        DispatchQueue.main.async {
            self.locationManager.stopUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    @objc private func appDidBecomeActive() {
        guard isAuthorized else { return }
        DispatchQueue.main.async {
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
//            Location access denied or restricted
            self.isAuthorized = false
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            self.isAuthorized = true
            locationManager.startUpdatingLocation()
        @unknown default:
//            Unknown authorization status
            print("Unknown authorization status")
            self.isAuthorized = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.location = location
        }
    }
}
