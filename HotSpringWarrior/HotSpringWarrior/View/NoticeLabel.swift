//
//  GameSystemLabel.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/02.
//
import UIKit

final class NoticeLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.numberOfLines = 0
        self.textAlignment = .center
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(text: String) {
        self.isHidden = false
        let strokeTextAttributes = [
            .strokeColor : UIColor.black,
            .strokeWidth : -5.0,
            .foregroundColor: UIColor.white,
            .font : UIFont.boldSystemFont(ofSize: 30.0)
            ] as [NSAttributedString.Key : Any]
        let textAnimation = TypingTextAnimation(text: text, attributes: strokeTextAttributes)
        textAnimation.animate(label: self, completion: {
            [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self?.isHidden = true
            })
        })
    }
}
