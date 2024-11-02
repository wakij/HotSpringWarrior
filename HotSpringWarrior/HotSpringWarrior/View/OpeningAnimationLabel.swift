//
//  OpeningAnimationLabel.swift
//  HotSpringWorrier
//
//  Created by tomoshigewakita on 2024/09/06.
//

import Foundation
import UIKit

final class OpeningAnimationLabel: TypingAnimationLabel {
    private var clearingDelay: TimeInterval = 2.0
    
    private let explainTextAttributes = [
        .foregroundColor: UIColor.white,
        .font : UIFont.boldSystemFont(ofSize: 22.0)
        ] as [NSAttributedString.Key : Any]
    
    private let tapToStartTextAttributes = [
        .foregroundColor: UIColor.white,
        .font : UIFont.boldSystemFont(ofSize: 30.0)
    ] as [NSAttributedString.Key : Any]
    
    func startAnimating() {
        super.startTyping(text: Opening.description, attributes: explainTextAttributes, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.clearingDelay) {
                self.attributedText = nil
                self.startTapToStart()
            }
        })
    }
    
    private func startTapToStart() {
        self.attributedText = NSAttributedString(string: Opening.tapToStart, attributes: tapToStartTextAttributes)
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 1.0
        animation.fromValue = UIColor.black.cgColor
        animation.toValue = UIColor.red.cgColor
        animation.autoreverses = true
        animation.repeatCount = 2
        animation.isRemovedOnCompletion = true
        self.layer.add(animation, forKey: nil)
    }
}
