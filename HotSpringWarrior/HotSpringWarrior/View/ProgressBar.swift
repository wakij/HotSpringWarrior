//
//  ProgressBar.swift
//  HotSpringWarrior
//
//  Created by wakita tomoshige on 2024/11/03.
//

import UIKit

class ProgressBar: UIView {

    // 進捗度合いを示すプロパティ
    var progress: Double = 0.0 {
        didSet {
            updateProgressBar()
        }
    }

    // UI要素
    private let backgroundBar = UIView()
    private let progressBar = UIView()

    // プログレスバーの幅制約
    private var progressBarWidthConstraint: NSLayoutConstraint?

    // グラデーションレイヤーをプロパティとして保持
    private let progressGradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // UIのセットアップ
    private func setupUI() {
        // 背景のバーの設定
        backgroundBar.backgroundColor = .white
        backgroundBar.layer.cornerRadius = 10
        backgroundBar.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(backgroundBar)

        NSLayoutConstraint.activate([
            backgroundBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundBar.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundBar.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        // 進捗を示すバーの設定
        progressBar.layer.cornerRadius = 10
        progressBar.layer.masksToBounds = true
        progressBar.layer.shadowColor = UIColor.purple.withAlphaComponent(0.3).cgColor
        progressBar.layer.shadowOffset = CGSize(width: 0, height: 3)
        progressBar.layer.shadowOpacity = 1.0
        progressBar.layer.shadowRadius = 5

        backgroundBar.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: backgroundBar.leadingAnchor, constant: 2),
            progressBar.centerYAnchor.constraint(equalTo: backgroundBar.centerYAnchor),
            progressBar.heightAnchor.constraint(equalTo: backgroundBar.heightAnchor, constant: -4)
        ])

        // 幅制約を保持
        progressBarWidthConstraint = progressBar.widthAnchor.constraint(equalToConstant: 0)
        progressBarWidthConstraint?.isActive = true
        
        progressGradientLayer.frame = self.bounds
        
        progressGradientLayer.colors = [
            UIColor(red: 0.98, green: 0.65, blue: 0.57, alpha: 1).cgColor, // サーモンピンク
            UIColor(red: 0.94, green: 0.33, blue: 0.31, alpha: 1).cgColor, // 温かみのある赤
            UIColor(red: 0.85, green: 0.22, blue: 0.21, alpha: 1).cgColor  // 濃い目の赤
        ]
        
        // グラデーションの位置
        progressGradientLayer.locations = [0.0, 0.5, 1.0]
        
        // グラデーションの方向（左から右へ）
        progressGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        progressGradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        progressBar.layer.addSublayer(progressGradientLayer)
    }

    // プログレスバーを更新する
    private func updateProgressBar() {
        let totalWidth = self.bounds.width
        let newWidth = CGFloat(progress) * totalWidth
        self.progressGradientLayer.frame = CGRect(origin: .zero, size: self.bounds.size)
        progressBarWidthConstraint?.constant = newWidth

        UIView.animate(withDuration: 1.0, animations: {
            self.layoutIfNeeded()
        })
    }
}
