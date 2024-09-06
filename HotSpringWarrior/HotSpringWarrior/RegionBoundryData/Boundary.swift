//
//  Boundary.swift
//  HotSpringWarrior
//
//  Created by tomoshigewakita on 2024/09/06.
//

import Foundation
import MapKit

struct Boundary {
    static var sampleUserTrajectory: [CLLocation] {
        let routeCSV = """
        35.54629459139776, 139.75617029682883
        35.54678344051146, 139.75619175450095
        35.54726355727582, 139.75592353359946
        35.54775240048236, 139.75476481930502
        35.5483285332926, 139.75345590130576
        35.548782453197205, 139.75359537617453
        35.549389824711774, 139.7543463946987
        35.55001131727305, 139.75487210766562
        """
        return Self.loadCSV(data: routeCSV)
    }
    
    static var otaRegion: [CLLocation] {
        if let filePath = Bundle.main.path(forResource: "otaRegion", ofType: "txt") {
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                return Self.loadCSV(data: fileContents)
            } catch {
                print("ファイルの読み込みに失敗しました: \(error)")
            }
        }
        fatalError("ファイルの読み込みに失敗しました")
    }
//    緯度、経度に関するcsV
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
