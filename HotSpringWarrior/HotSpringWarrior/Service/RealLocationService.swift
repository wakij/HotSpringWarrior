//
//  RealLocationService.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/31.
//
import CoreLocation
import UIKit

final class RealLocationService: NSObject, LocationService {
    weak var delegate: LocationServiceDelegate?
    var locationManager: CLLocationManager
    var userTrajectory: [CLLocation] = .init()
    
    override init() {
        locationManager = CLLocationManager()
    }
    
    func startUpdatingLocation() {
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension RealLocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
//            Alertを出して設定から変更してもらう必要がありそう
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        userTrajectory.append(loc)

//        UIの更新はフォアグラウンドにいる時に限定する
        if UIApplication.shared.applicationState == .active {
            delegate?.locationService(self, didUpdateLocations: userTrajectory)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        delegate?.locationService(self, didFailWithError: error)
    }
}
