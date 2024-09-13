//
//  ViewController.swift
//  study_ios_always_location_permission
//
//  Created by Wing on 28/7/2024.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        requestLocationPermission()
    }

    func requestLocationPermission() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        print("Current authorization status: \(authorizationStatus.rawValue)")

        if authorizationStatus == .notDetermined {
            // 首次請求「使用時」位置權限
            print("Requesting 'When In Use' authorization")
            locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .authorizedWhenInUse {
            // 如果已經授予「使用時」位置權限，請求「始終」位置權限
            print("Requesting 'Always' authorization")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.locationManager.requestAlwaysAuthorization()
            }
        } else if authorizationStatus == .authorizedAlways {
            // 「始終」位置權限已授予
            print("Already have 'Always' authorization")
        } else {
            print("Authorization status is neither 'notDetermined' nor 'authorizedWhenInUse'")
        }
    }

    // CLLocationManagerDelegate方法
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed: \(status.rawValue)")
        if status == .authorizedWhenInUse {
            // 當授予「使用時」位置權限後，再次請求「始終」位置權限
            print("Authorized 'When In Use', requesting 'Always' authorization")
            self.locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways {
            // 「始終」位置權限已授予
            print("Authorized 'Always' location access")
        } else {
            print("Authorization status is neither 'authorizedWhenInUse' nor 'authorizedAlways'")
        }
    }
}
