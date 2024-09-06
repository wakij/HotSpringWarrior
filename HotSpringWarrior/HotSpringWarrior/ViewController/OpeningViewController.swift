//
//  OpeningViewController.swift
//  HotSpringWorrier
//
//  Created by tomoshigewakita on 2024/09/05.
//

import Foundation
import UIKit

class OpeningViewController: UIViewController {
    
    override func viewDidLoad() {
        self.view.backgroundColor = .clear
        
        let titleLabel = TitleLabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        
        let openingLabel = OpeningAnimationLabel(frame: .zero)
        openingLabel.numberOfLines = 0
        openingLabel.translatesAutoresizingMaskIntoConstraints = false
        openingLabel.textAlignment = .center
        self.view.addSubview(openingLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120),
            openingLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            openingLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            openingLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            openingLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5),
        ])
        
        openingLabel.startLabelAnimation()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(startGame))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func startGame() {
        let gameVc = GameViewController()
        gameVc.modalPresentationStyle = .fullScreen
        present(gameVc, animated: true)
    }
}
