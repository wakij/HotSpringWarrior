//
//  TextAnimationStrategy.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/02.
//
import UIKit

protocol TextAnimationStrategy {
    func animate(label: UILabel, completion: @escaping () -> Void)
}
