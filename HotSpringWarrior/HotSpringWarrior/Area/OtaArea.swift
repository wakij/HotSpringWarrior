//
//  OtaBoundary.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/20.
//
import MapKit

struct OtaArea: Area {
    var name: String = "大田区"
    
    var boundary: [CLLocation] = {
        if let filePath = Bundle.main.path(forResource: "otaArea", ofType: "txt") {
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                return AreaCSVLoader.loadCSV(data: fileContents)
            } catch {
                print("ファイルの読み込みに失敗しました: \(error)")
            }
        }
        fatalError("ファイルの読み込みに失敗しました")
    }()
    
    var eventSpots: [PointAnnotation] = [
        .init(identifier: "omorikaizuka", coordinate: .init(latitude: 35.59309609576951, longitude: 139.73022441785574)),
        .init(identifier: "ikegamihonmonzi", coordinate: .init(latitude: 35.57897593347053, longitude: 139.7062327879064)),
        .init(identifier: "senzokuike", coordinate: .init(latitude: 35.601683209201504, longitude: 139.69059873393968)),
        .init(identifier: "nishirokugo", coordinate: .init(latitude: 35.5532766, longitude: 139.711654))
    ]
}
