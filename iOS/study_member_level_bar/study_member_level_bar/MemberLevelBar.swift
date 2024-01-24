//
//  MemberLevelBar.swift
//  study_member_level_bar
//
//  Created by Wing CHAN on 24/1/2024.
//

import Foundation
import TinyConstraints
import UIKit

public class MemberLevelBar: UIView {
    private let progressView = CustomProgressView()

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(progressView)
        progressView.edgesToSuperview()
        progressView.widthToSuperview()
        progressView.height(4)
    }

    public func updateProgress(to progress: CGFloat) {
        progressView.updateProgress(to: progress)
    }
}

private class CustomProgressView: UIView {
    private let progressView = UIView()
    private let thumbView = UIView()
    private let gradientLayer = CAGradientLayer()

    private var currentProgress: CGFloat = 0
    private var thumbViewSize: CGSize {
        CGSize(width: self.bounds.height * 1.5, height: self.bounds.height * 1.5)
    }

    private var thumbViewCornerRadius: CGFloat { self.thumbViewSize.height / 2 }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
        setupThumbView()
        setupGradientBackground()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateProgress(to: currentProgress, animated: false)
        thumbView.layer.cornerRadius = thumbViewCornerRadius
    }

    private func setupProgressView() {
        progressView.backgroundColor = .blue
        addSubview(progressView)
    }

    private func setupThumbView() {
        thumbView.backgroundColor = .red
        thumbView.clipsToBounds = true
        addSubview(thumbView)
    }

    private func setupGradientBackground() {
        gradientLayer.colors = [
            // #403826
            UIColor(red: 0.251, green: 0.22, blue: 0.149, alpha: 1).cgColor,
            // #40382600
            UIColor(red: 0.251, green: 0.22, blue: 0.149, alpha: 0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        layer.insertSublayer(gradientLayer, at: 0)
    }

    func updateProgress(to progress: CGFloat, animated: Bool = true) {
        guard progress >= 0 && progress <= 1 else { return }
        currentProgress = progress

        let updateFrame = { [weak self] in
            guard let self = self else { return }
            let progressWidth = self.bounds.width * progress
            self.progressView.frame = CGRect(x: 0, y: 0, width: progressWidth, height: self.bounds.height)
            self.thumbView.frame = CGRect(
                x: progressWidth - thumbViewCornerRadius,
                y: self.bounds.height / 2 - thumbViewCornerRadius,
                width: thumbViewSize.width,
                height: thumbViewSize.height
            )
        }

        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                updateFrame()
            })
        } else {
            updateFrame()
        }
    }
}
