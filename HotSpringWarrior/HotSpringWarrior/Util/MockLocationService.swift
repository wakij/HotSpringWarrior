//
//  Untitled.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/31.
//
import CoreLocation
import Foundation

final class MockLocationService: NSObject, LocationService {
    weak var delegate: LocationServiceDelegate?
    private var timer: Timer?
    private var mockRoute: [CLLocation] = [
        .init(latitude: 35.54629459139776, longitude: 139.75617029682883),
        .init(latitude: 35.54678344051146, longitude: 139.75619175450095),
        .init(latitude: 35.54726355727582, longitude: 139.75592353359946),
        .init(latitude: 35.54775240048236, longitude: 139.75476481930502),
        .init(latitude: 35.5483285332926, longitude: 139.75345590130576),
        .init(latitude: 35.548782453197205, longitude: 139.75359537617453),
        .init(latitude: 35.549389824711774, longitude: 139.7543463946987),
        .init(latitude: 35.55001131727305, longitude: 139.75487210766562)
    ]
    
    var userTrajectory: [CLLocation] = .init()
    
    func startUpdatingLocation() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !mockRoute.isEmpty {
                let newLoc = mockRoute.removeLast()
                userTrajectory.append(newLoc)
                self.delegate?.locationService(self, didUpdateLocations: userTrajectory)
            } else {
                timer?.invalidate()
            }
        }
    }
    
    func stopUpdatingLocation() {
        timer?.invalidate()
        timer = nil
        return
    }
}
