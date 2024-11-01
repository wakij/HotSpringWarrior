//
//  HoldHotWaterAnimation.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/31.
//
import UIKit

class HoldHotWaterAnimation: NSObject, Animation {
    private let completion: () -> Void
    private let fromValue: CGRect
    private let toValue: CGRect
    
    init(fromValue: CGRect, toValue: CGRect, completion: @escaping () -> Void) {
        self.fromValue = fromValue
        self.toValue = toValue
        self.completion = completion
    }
    
    func start(on layer: CALayer) {
        layer.backgroundColor = UIColor.black.cgColor
        let maskAnimation = CABasicAnimation(keyPath: "bounds")
        maskAnimation.fromValue = NSValue(cgRect: fromValue)
        maskAnimation.toValue = NSValue(cgRect: toValue)
        maskAnimation.duration = 5
        maskAnimation.repeatCount = 1
        maskAnimation.isRemovedOnCompletion = true
        maskAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        maskAnimation.delegate = self
        layer.add(maskAnimation, forKey: "HoldHotWaterAnimation")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            completion()
        }
    }
}
