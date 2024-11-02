//
//  TypingAnimation.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/02.
//
import UIKit

class TypingTextAnimation: TextAnimationStrategy {
    
    // タイピングの速度
    var typingSpeed: TimeInterval = 0.1

    private var typingTimer: Timer?
    private var currentIndex: Int = 0
    
    private(set) var displayText: String
    private(set) var displayingText = ""
    let attributes: [NSAttributedString.Key: Any]
    
    init(text: String, typingSpeed: TimeInterval = 0.1, attributes: [NSAttributedString.Key : Any]) {
        self.typingSpeed = typingSpeed
        self.displayText = text
        self.attributes = attributes
    }
    
    func animate(label: UILabel, completion: @escaping () -> Void) {
        currentIndex = 0
        typingTimer?.invalidate()
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.currentIndex < displayText.count {
                let index = displayText.index(displayText.startIndex, offsetBy: self.currentIndex)
                self.displayingText.append(displayText[index])
                label.attributedText = NSAttributedString(string: displayingText, attributes: attributes)
                self.currentIndex += 1
            } else {
                // 全てのテキストを表示したらタイマーを停止して一定時間後にクリア
                timer.invalidate()
                typingTimer = nil
                completion()
            }
        }
    }
}
