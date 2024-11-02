//
//  Boundary.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/20.
//

import MapKit

protocol Area {
    var name: String { get }
    var boundary: [CLLocation] { get }
    var eventSpots: [PointAnnotation] { get }
}

extension Area {
    var boundingRect: MKMapRect {
        let boundaryPolygon = MKPolygon(coordinates: boundary.map({ $0.coordinate }), count: boundary.count)
        return boundaryPolygon.boundingMapRect
    }
}
