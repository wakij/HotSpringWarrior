//
//  Game.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/02.
//
enum Game {
    static let getHotWater = "お湯を手に入れた！\n洗浄しに街を回ろう"
    static func completeMessage(areaName: String, percentage: Double) -> String {
        return "清掃終了!\n\(areaName)の\(String(format: "%.1f", percentage))%を清掃をできました！"
    }
}
