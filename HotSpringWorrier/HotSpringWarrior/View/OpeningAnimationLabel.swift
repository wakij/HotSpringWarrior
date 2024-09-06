//
//  OpeningAnimationLabel.swift
//  HotSpringWorrier
//
//  Created by tomoshigewakita on 2024/09/06.
//

import Foundation
import UIKit

//使いまわしたいけど挙動が特殊すぎる
final class OpeningAnimationLabel: UILabel {

    // タイピングの速度
    private var typingSpeed: TimeInterval = 0.1
    
    // テキストが全て表示された後に消すまでの待ち時間
    private var clearingDelay: TimeInterval = 2.0

    private var typingTimer: Timer?
    private var currentIndex: Int = 0

    private let displayText: String = "悪の組織により私たちの大田区が\n汚されてしまった...\n矢口 渡とともに銭湯のお湯で\n汚れを洗い流していこう!!!"
    private var displayingText = ""
    
    private let explainTextAttributes = [
//        .strokeColor : UIColor.black,
//        .strokeWidth : -5.0,
        .foregroundColor: UIColor.white,
        .font : UIFont.boldSystemFont(ofSize: 22.0)
        ] as [NSAttributedString.Key : Any]
    
    private let tapToStartTextAttributes = [
        .foregroundColor: UIColor.white,
        .font : UIFont.boldSystemFont(ofSize: 30.0)
    ] as [NSAttributedString.Key : Any]
    
    func startLabelAnimation() {
        self.attributedText = nil
        currentIndex = 0
        typingTimer?.invalidate()
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.currentIndex < displayText.count {
                let index = displayText.index(displayText.startIndex, offsetBy: self.currentIndex)
                self.displayingText.append(displayText[index])
                self.attributedText = NSAttributedString(string: displayingText, attributes: explainTextAttributes)
                self.currentIndex += 1
            } else {
                // 全てのテキストを表示したらタイマーを停止して一定時間後にクリア
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + self.clearingDelay) {
                    self.attributedText = nil
                    self.startTapToStart()
                }
            }
        }
    }
    
    private func startTapToStart() {
        self.attributedText = NSAttributedString(string: "tap to start", attributes: tapToStartTextAttributes)
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
