//
//  BlinkingTextAnimation.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/02.
//
import UIKit

class BlinkingTextAnimation: TextAnimationStrategy {
    let text: String
    let attributes: [NSAttributedString.Key : Any]
    
    init(text: String, attributes: [NSAttributedString.Key : Any]) {
        self.text = text
        self.attributes = attributes
    }
    
    func animate(label: UILabel, completion: @escaping () -> Void) {
        label.attributedText = NSAttributedString(string: text, attributes: self.attributes)
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 1.0
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.autoreverses = true
        animation.repeatCount = 2
        animation.isRemovedOnCompletion = true
        label.layer.add(animation, forKey: nil)
    }
}
