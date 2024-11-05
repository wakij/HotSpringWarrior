//
//  OpeningAnimationLabel.swift
//  HotSpringWorrier
//
//  Created by tomoshigewakita on 2024/09/06.
//

import Foundation
import UIKit

final class OpeningLabel: UILabel {
    var clearingDelay: TimeInterval = 2.0
    private var textAnimation: TextAnimationStrategy?
    
    private let explainTextAttributes = [
        .foregroundColor: UIColor.white,
        .font : UIFont.boldSystemFont(ofSize: 22.0)
        ] as [NSAttributedString.Key : Any]
    
    private let tapToStartTextAttributes = [
        .foregroundColor: UIColor.white,
        .font : UIFont.boldSystemFont(ofSize: 30.0)
    ] as [NSAttributedString.Key : Any]
    
    func startAnimating() {
        let textAnimation = TypingTextAnimation(text: Opening.description, attributes: explainTextAttributes)
        self.textAnimation = textAnimation
        textAnimation.animate(label: self, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.clearingDelay) {
                self.attributedText = nil
                self.startTapToStart()
            }
        })
    }
    
    private func startTapToStart() {
        let textAnimation = BlinkingTextAnimation(text: Opening.tapToStart, attributes: tapToStartTextAttributes)
        self.textAnimation = textAnimation
        textAnimation.animate(label: self, completion: {})
    }
}
