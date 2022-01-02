//
//  class.swift
//  HapticRoad
//
//  Created by 황지은 on 2021/09/26.
//

import Foundation
import CoreLocation

class Location {
    static let shared = Location()
    var locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("위도: \(location.coordinate.latitude)")
            print("경도: \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    private init() { }
}
