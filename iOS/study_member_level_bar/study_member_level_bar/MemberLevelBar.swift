//
//  MemberLevelBar.swift
//  study_member_level_bar
//
//  Created by Wing CHAN on 24/1/2024.
//

import Foundation
import Then
import TinyConstraints
import UIKit

public class MemberLevelBar: UIView {
    struct DisplayModel {
        let infoViewGradientColors: [CGColor]
        let levelViewBackgroundColor: UIColor
        let levelViewAttributedText: NSAttributedString
        let amountAttributedText: NSAttributedString
        let progress: CGFloat
        let progressViewGradientColors: [CGColor]
    }
    
    private let infoView = InfoView()
    private let progressView = CustomProgressView()

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(infoView)
        addSubview(progressView)
        infoView.do {
            $0.topToSuperview()
            $0.leftToSuperview()
            $0.rightToSuperview(relation: .equalOrLess)
            $0.bottomToTop(of: progressView)
        }
        progressView.do {
            $0.edgesToSuperview(excluding: .top)
            $0.widthToSuperview()
            $0.height(4)
        }
    }

    func configure(with model: DisplayModel) {
        infoView.configure(
            with: InfoView.DisplayModel(
                gradientColors: model.infoViewGradientColors,
                levelTextDisplayModel: BorderLabelView.DisplayModel(
                    backgroundColor: model.levelViewBackgroundColor,
                    attributedText: model.levelViewAttributedText
                ),
                amountAttributedText: model.amountAttributedText
            )
        )
        progressView.configure(
            with: CustomProgressView.DisplayModel(
                progress: model.progress,
                gradientColors: model.progressViewGradientColors
            )
        )
    }
}

private class InfoView: UIView {
    struct DisplayModel {
        let gradientColors: [CGColor]
        let levelTextDisplayModel: BorderLabelView.DisplayModel
        let amountAttributedText: NSAttributedString
    }
    
    private let gradientLayer = CAGradientLayer()
    private let hStack = UIStackView()
    private let levelLabelView = BorderLabelView()
    let amountLabel = UILabel()
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
        
        let clipPath = borderPath(rect: self.bounds)
        let maskLayer = CAShapeLayer()
        maskLayer.path = clipPath.cgPath
        self.layer.mask = maskLayer
    }
    
    private func setupViews() {
        addSubview(hStack)
        layer.insertSublayer(gradientLayer, at: 0)
        
        gradientLayer.do {
            $0.locations = [0.0, 1.0]
            $0.startPoint = CGPoint(x: 0.83, y: 0)
            $0.endPoint = CGPoint(x: 0.83, y: 0.93)
        }
        
        hStack.do {
            $0.addArrangedSubview(levelLabelView)
            $0.setCustomSpacing(4, after: levelLabelView)
            $0.addArrangedSubview(amountLabel)
            $0.edgesToSuperview(insets: .init(top: 8, left: 8, bottom: 8, right: 20))
        }

        clipsToBounds = true
    }
    
    private func borderPath(rect: CGRect) -> UIBezierPath {
        let topLeftRadius: CGFloat = 8
        let topRightRadius: CGFloat = 16
        let bottomRightRadius: CGFloat = 12
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
        path.addArc(
            withCenter: CGPoint(
                x: rect.minX + topLeftRadius,
                y: rect.minY + topLeftRadius
            ),
            radius: topLeftRadius,
            startAngle: CGFloat(Double.pi),
            endAngle: CGFloat(3 * Double.pi / 2),
            clockwise: true
        )
        path.addLine(to: CGPoint(x: rect.maxX - topRightRadius - bottomRightRadius, y: rect.minY))
        path.addArc(
            withCenter: CGPoint(
                x: rect.maxX - topRightRadius - bottomRightRadius,
                y: rect.minY + topRightRadius
            ),
            radius: topRightRadius,
            startAngle: CGFloat(3 * Double.pi / 2),
            endAngle: CGFloat(0),
            clockwise: true
        )
        path.addLine(to: CGPoint(x: rect.maxX - bottomRightRadius, y: rect.maxY - bottomRightRadius))
        path.addArc(
            withCenter: CGPoint(
                x: rect.maxX,
                y: rect.maxY - bottomRightRadius
            ),
            radius: bottomRightRadius,
            startAngle: CGFloat(Double.pi),
            endAngle: CGFloat(Double.pi / 2),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.close()
        return path
    }
    
    func configure(with model: DisplayModel) {
        levelLabelView.configure(with: model.levelTextDisplayModel)
        amountLabel.attributedText = model.amountAttributedText
        gradientLayer.colors = model.gradientColors
    }
}
    
private class BorderLabelView: UIView {
    struct DisplayModel {
        let backgroundColor: UIColor
        let attributedText: NSAttributedString
    }
        
    private let label = UILabel()
    init() {
        super.init(frame: .zero)
        setupViews()
    }
        
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupViews() {
        addSubview(label)
        layer.cornerRadius = 4
        label.do {
            $0.edgesToSuperview(insets: .init(top: 2, left: 4, bottom: 0, right: 4))
        }
    }
        
    func configure(with model: DisplayModel) {
        backgroundColor = model.backgroundColor
        label.attributedText = model.attributedText
    }
}
    
private class CustomProgressView: UIView {
    struct DisplayModel {
        let progress: CGFloat
        let gradientColors: [CGColor]
    }
        
    private let progressView = UIView()
    private let thumbView = UIView()
    private let gradientLayer = CAGradientLayer()
        
    private var currentProgress: CGFloat = 0
    private var thumbViewSize: CGSize {
        CGSize(width: self.bounds.height * 1.5, height: self.bounds.height * 1.5)
    }
        
    private var thumbViewCornerRadius: CGFloat { self.thumbViewSize.height / 2
    }

    // #C7A353
    private let progressColor = UIColor(red: 0.78, green: 0.639, blue: 0.325, alpha: 1)
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressView()
        setupThumbView()
        setupGradientBackground()
    }
        
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateProgress(to: currentProgress, animated: false)
        thumbView.layer.cornerRadius = thumbViewCornerRadius
    }
        
    private func setupProgressView() {
        progressView.backgroundColor = progressColor
        addSubview(progressView)
    }
        
    private func setupThumbView() {
        thumbView.backgroundColor = progressColor
        thumbView.clipsToBounds = true
        addSubview(thumbView)
    }
        
    private func setupGradientBackground() {
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            
        layer.insertSublayer(gradientLayer, at: 0)
    }
        
    private func updateProgress(to progress: CGFloat, animated: Bool = true) {
        guard progress >= 0 && progress <= 1 else { return }
        currentProgress = progress
            
        let updateFrame = { [weak self] in
            guard let self = self else { return }
            let minProgress: CGFloat = 10 / 355
            let progressWidth = self.bounds.width * max(progress, minProgress)
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
        
    func configure(with model: DisplayModel) {
        updateProgress(to: model.progress)
        gradientLayer.colors = model.gradientColors
    }
}
