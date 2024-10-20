//
//  AreaCSVLoader.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/20.
//

import MapKit

final class AreaCSVLoader {
    static func loadCSV(data: String) -> [CLLocation] {
        let lines = data.split(separator: "\n")
        var locations: [CLLocation] = []
        for line in lines {
            let coordinates = line.split(separator: ", ").compactMap({ Double($0) })
            if coordinates.count != 2 { fatalError("不正なcsvです") }
            let location = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
            locations.append(location)
        }
        return locations
    }
}
