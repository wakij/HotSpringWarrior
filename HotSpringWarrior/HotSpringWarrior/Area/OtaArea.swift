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
        if let filePath = Bundle.main.path(forResource: "otaRegion", ofType: "txt") {
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                return AreaCSVLoader.loadCSV(data: fileContents)
            } catch {
                print("ファイルの読み込みに失敗しました: \(error)")
            }
        }
        fatalError("ファイルの読み込みに失敗しました")
    }()
}
