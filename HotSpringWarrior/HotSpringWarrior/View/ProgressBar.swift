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
    private let gradientLayer = CAGradientLayer()

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
        backgroundBar.backgroundColor = UIColor.white
        backgroundBar.layer.cornerRadius = 10
        backgroundBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        backgroundBar.layer.shadowOffset = CGSize(width: 0, height: 3)
        backgroundBar.layer.shadowOpacity = 1.0
        backgroundBar.layer.shadowRadius = 5
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
        progressBar.backgroundColor = .green
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
    }

    // プログレスバーを更新する
    private func updateProgressBar() {
        let totalWidth = self.bounds.width
        let newWidth = CGFloat(progress) * totalWidth
        progressBarWidthConstraint?.constant = newWidth

        UIView.animate(withDuration: 1.0, animations: {
            self.layoutIfNeeded()
        })
    }
}
