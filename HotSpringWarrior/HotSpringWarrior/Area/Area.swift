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
    var eventSpots: [EventSpot] { get }
}

extension Area {
    
    func getEventSpot(from text: String) -> EventSpot? {
        return eventSpots.first(where: { $0.identifier == text })
    }
    
    var boundingMapRect: MKMapRect {
        let boundaryPolygon = MKPolygon(coordinates: boundary.map({ $0.coordinate }), count: boundary.count)
        return boundaryPolygon.boundingMapRect
    }
}
