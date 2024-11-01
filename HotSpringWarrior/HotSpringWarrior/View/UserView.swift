//
//  UserView.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/10/31.
//
import UIKit
import MapKit

final class UserView: MKAnnotationView {
    let imageView: UIImageView
    override init(annotation: (any MKAnnotation)?, reuseIdentifier: String?) {
        self.imageView = UIImageView(image: UIImage(named: "yaguchiNormal"))
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.imageView.widthAnchor.constraint(equalToConstant: .init(60)),
            self.imageView.heightAnchor.constraint(equalToConstant: .init(60))
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        self.imageView.animationImages = [
            UIImage(named: "yaguchiFront")!,
            UIImage(named: "yaguchiLeft")!,
            UIImage(named: "yaguchiRight")!
        ]
        self.imageView.animationDuration = 1.0
        self.imageView.animationRepeatCount = 0
        self.imageView.startAnimating()
    }

    func stopWalkingAnimation() {
        self.imageView.animationImages = nil
        self.imageView.stopAnimating()
    }
}
