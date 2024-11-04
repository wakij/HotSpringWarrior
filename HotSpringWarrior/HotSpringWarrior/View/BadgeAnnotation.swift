//
//  BadgeAnnotation.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/02.
//
import MapKit

class PointAnnotation: MKPointAnnotation {
    let identifier: String
    init(identifier: String, coordinate: CLLocationCoordinate2D) {
        self.identifier = identifier
        super.init()
        self.coordinate = coordinate
    }
}
