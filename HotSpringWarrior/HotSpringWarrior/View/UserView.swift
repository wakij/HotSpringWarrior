//
//  UserView.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/31.
//
import UIKit

final class UserView: UIImageView {
    init(center: CGPoint) {
        super.init(frame: .zero)
        self.image = UIImage(named: "yaguchiNormal")
        self.bounds.size = CGSize(width: 100, height: 100)
        self.center = center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func holdHotWater(completion: @escaping () -> Void) {
        let maskLayer = CALayer()
        maskLayer.frame = self.bounds
        self.layer.mask = maskLayer
        let anim = HoldHotWaterAnimation(
            fromValue: self.bounds,
            toValue: CGRect(x: 0, y: 0, width: self.bounds.width, height: 0)) {
                completion()
            }
        anim.start(on: maskLayer)
    }
    
    func startWalkingAnimation() {
        self.animationImages = [
            UIImage(named: "yaguchiFront")!,
            UIImage(named: "yaguchiLeft")!,
            UIImage(named: "yaguchiRight")!
        ]
        self.animationDuration = 1.0
        self.animationRepeatCount = 0
        self.startAnimating()
    }
    
    func stopWalkingAnimation() {
        self.animationImages = nil
        self.stopAnimating()
    }
}
