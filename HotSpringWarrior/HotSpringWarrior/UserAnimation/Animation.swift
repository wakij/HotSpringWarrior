//
//  UserAnimation.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/31.
//
import UIKit

protocol Animation: CAAnimationDelegate {
    func start(on layer: CALayer)
}
