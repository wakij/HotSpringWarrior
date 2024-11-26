//
//  PiyoParkArea.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/05.
//
import MapKit

struct PioParkArea: Area {
    var name: String = "ピオパーク"
    
    var boundary: [CLLocation] = {
        if let filePath = Bundle.main.path(forResource: "pioPark", ofType: "txt") {
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                return AreaCSVLoader.loadCSV(data: fileContents)
            } catch {
                print("ファイルの読み込みに失敗しました: \(error)")
            }
        }
        fatalError("ファイルの読み込みに失敗しました")
    }()
    
    var eventSpots: [EventSpot] = []
}
