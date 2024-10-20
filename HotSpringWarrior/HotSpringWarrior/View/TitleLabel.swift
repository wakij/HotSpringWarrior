//
//  TitleLabel.swift
//  HotSpringWorrier
//
//  Created by tomoshigewakita on 2024/09/06.
//

import Foundation
import UIKit

final class TitleLabel: UILabel {
    private let titleTextAttributes = [
        .strokeColor : UIColor.white,
        .strokeWidth : -2.0,
        .foregroundColor: UIColor.red,
        .font : UIFont.boldSystemFont(ofSize: 50.0)
        ] as [NSAttributedString.Key : Any]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.numberOfLines = 2
        self.textAlignment = .center
        self.attributedText = NSAttributedString(string: Opening.title, attributes: titleTextAttributes)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
