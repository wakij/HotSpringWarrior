//
//  Ex+UIView.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/04.
//
import UIKit

extension UIView {
    static func animate(
        withDuration duration: TimeInterval,
        animations: @escaping () -> Void
    ) async {
        await withCheckedContinuation { continuation in
            UIView.animate(withDuration: duration, animations: animations) { _ in
                continuation.resume()
            }
        }
    }
}
