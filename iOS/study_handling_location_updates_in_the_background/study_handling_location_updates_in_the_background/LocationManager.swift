//
//  LocationManager.swift
//  study_handling_location_updates_in_the_background
//
//  Created by Wing on 2/5/2024.
//

import CoreLocation
import Foundation

class LocationManager: NSObject {
    private let manager = CLLocationManager()

    override init() {
        super.init()

        CustomSupabaseClient.shared.insertData(message: "LocationManager.init")
        manager.delegate = self
        // https://medium.com/@le821227/swift-about-location-c98e605abb0d
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    private func enableLocationFeatures() {
        CustomSupabaseClient.shared.insertData(message: "LocationManager: enableLocationFeatures")
        manager.startUpdatingLocation()
        // https://developer.apple.com/documentation/corelocation/cllocationmanager/1423531-startmonitoringsignificantlocati
        manager.startMonitoringSignificantLocationChanges()
    }

    private func disableLocationFeatures() {
        CustomSupabaseClient.shared.insertData(message: "LocationManager: disableLocationFeatures")
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        CustomSupabaseClient.shared.insertData(message: "LocationManager: didUpdateLocations: \(location.coordinate)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        CustomSupabaseClient.shared.insertData(message: "Unknown error occurred while handling location manager error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        CustomSupabaseClient.shared.insertData(message: "LocationManager: locationManagerDidChangeAuthorization: \(manager.authorizationStatus)")
        switch manager.authorizationStatus {
        case .authorizedAlways:
            enableLocationFeatures()
        case .authorizedWhenInUse: // Location services are available.
            manager.requestAlwaysAuthorization()
        case .restricted, .denied: // Location services currently unavailable.
            disableLocationFeatures()
        case .notDetermined: // Authorization not determined yet.
            manager.requestAlwaysAuthorization()
        default:
            break
        }
    }
}
