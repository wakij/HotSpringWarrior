//
//  LocationService.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/31.
//
import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func locationService(_ service: LocationService, didUpdateLocations locations: [CLLocation])
    func locationService(_ service: LocationService, didFailWithError error: Error)
}

protocol LocationService: AnyObject {
    var delegate: LocationServiceDelegate? { get set }
    var userTrajectory: [CLLocation] { get }
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
