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
}
