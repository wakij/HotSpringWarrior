//
//  GameSystemLabel.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/02.
//
import UIKit

final class NoticeLabel: UILabel {
    var textAnimation: TextAnimationStrategy?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.numberOfLines = 0
        self.textAlignment = .center
        self.isHidden = true
        
        self.layer.shadowColor = UIColor.black.cgColor // シャドウの色を黒に設定
        self.layer.shadowOffset = CGSize(width: 1, height: 1) // シャドウのオフセットを設定
        self.layer.shadowOpacity = 0.7 // シャドウの不透明度を設定
        self.layer.shadowRadius = 2.0 // シャドウの半径を設定
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(text: String, completion: @escaping (() -> Void)) {
        self.isHidden = false
        let strokeTextAttributes = [
            .foregroundColor: UIColor.white,
            .font : UIFont.boldSystemFont(ofSize: 30.0)
            ] as [NSAttributedString.Key : Any]
        let textAnimation = TypingTextAnimation(text: text, attributes: strokeTextAttributes)
        self.textAnimation = textAnimation
        textAnimation.animate(label: self, completion: completion)
    }
    
    func show(text: String) async throws {
        await withCheckedContinuation { continuation in
            show(text: text, completion: {
                continuation.resume()
            })
        }
    }
}
